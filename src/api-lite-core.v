/*
 * src/api-lite-core.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.2.7
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The main module of the daemon ----------------------------------------------

module main

import log
import veb
import os
import db.sqlite
import strconv

import vseryakov.syslog as s

import helper     as h
import controller as c

// CustomersApiLiteApp The main web app struct containing arbitrary data
// that are accessible by all endpoints and shared between different routes.
pub struct CustomersApiLiteApp {
    dbg bool
    cnx sqlite.DB
mut:
    l   log.Log
}

// RequestContext The struct containing data that are specific to each request.
// It also holds a standard HTTP request/response pair.
pub struct RequestContext {
    veb.Context
}

struct Error_ {
    error string
}

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    // Getting the daemon settings.
    settings := h.get_settings_()

    daemon_name := settings.value(h.daemon_name_).string()

    // Identifying whether debug logging is enabled.
    dbg := settings.value(h.log_enabled_).bool()

    // Creating and configuring the main logger of the daemon.
    mut l := log.Log{}

    // Suppressing the following temporary service message:
    // NOTE: the `log.Log` output goes to stderr now by default, not to stdout.
    l.set_output_stream(os.stderr())

    if !os.exists(h.log_dir_) { os.mkdir(h.log_dir_, os.MkdirParams{})! }

    l.set_custom_time_format(h.logtime_)
    l.set_always_flush(true)
    l.set_full_logpath(h.log_dir_ + h.logfile_)
    l.log_to_console_too()

    // Getting the port number used to run the inbuilt web server.
    server_port := h.get_server_port_(settings, mut l)

    // Opening the system logger.
    // Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
    s.open(os.base(os.args[0]), s.log_cons | s.log_pid, s.log_daemon)

    h.dbg_(dbg, mut l, h.o_bracket + daemon_name + h.c_bracket)

    // Getting the SQLite database path.
    database_path := settings.value(h.database_path_).string()

    // Trying to connect to the database.
    mut cnx := sqlite.connect(database_path) or {
        l.error(h.err_database_cannot_connect)

        h.cleanup_(mut l)

        exit(h.exit_failure)
    }

    h.dbg_(dbg, mut l, h.o_bracket + cnx.str() + h.c_bracket)

    l.info(h.msg_server_started + '${server_port}')
    s.info(h.msg_server_started + '${server_port}')

    // Attaching Unix signal handlers to ensure daemon clean shutdown.
    os.signal_opt(.int,  h.cleanup__)! // <== SIGINT
    os.signal_opt(.term, h.cleanup__)! // <== SIGTERM

    mut app := &CustomersApiLiteApp{
        dbg: dbg
        l:   l
        cnx: cnx
    }

    // Trying to start up the inbuilt web server.
    veb.run_at[CustomersApiLiteApp, RequestContext](mut app, port: server_port,
        show_startup_message: false) or {
            if err.msg().match_glob(h.err_eaddrinuse_glob) {
                l.error(h.err_cannot_start_server + h.err_addr_already_in_use)
            } else {
                l.error(h.err_cannot_start_server + h.err_serv_unknown_reason)
            }

            cnx.close()!

            h.cleanup_(mut l)

            exit(h.exit_failure)
        }
} // End main.

// REST API endpoints ---------------------------------------------------------

// add_list_customers The compound `PUT /v1/customers`
//                               / `GET /v1/customers` endpoint.
//
// 1. `PUT /v1/customers`. Creates a new customer (puts customer data
//                         to the database).
//
// The request body is defined exactly in the form
// as `{"name":"{customer_name}"}`. It should be passed with the accompanied
// request header `content-type` just like the following:
//
// `-H 'content-type: application/json' -d '{"name":"{customer_name}"}'`
//
// `{customer_name}` is a name assigned to a newly created customer.
//
// @param `ctx` The struct containing an HTTP request/response pair.
//
// @returns The `Result` struct with the `201 Created` HTTP status code,
//          the `Location` response header (among others), and the response
//          body in JSON representation, containing profile details
//          of a newly created customer.
//          May return client or server error depending on incoming request.
//
// 2. `GET /v1/customers`. Retrieves from the database and lists all
//                         customer profiles.
//
// @returns The `Result` struct with the `200 OK` HTTP status code
//          and the response body in JSON representation,
//          containing a list of all customer profiles.
//          May return client or server error depending on incoming request.
@['/v1/customers'; put; get; head; post; patch; delete; options; trace]
pub fn (mut app CustomersApiLiteApp) add_list_customers(mut ctx RequestContext)
    veb.Result {

    method := ctx.req.method

    h.dbg_(app.dbg, mut app.l, h.o_bracket + method.str() + h.c_bracket)

    if method == .put {
        // Creating a new customer (putting customer data to the database).
        customer := c.put_customer(app.dbg, mut app.l, app.cnx, ctx.req.data)

        // Validating the request payload through the return value
        // ("empty customer") from controller.
        if (customer.id == 0) && (customer.name == h.space) {
            ctx.res.set_status(.bad_request) // <== HTTP 400 Bad Request

            return ctx.json(Error_{ error: h.err_req_malformed })
        }

        ctx.res.header.add(.location, h.slash + h.rest_version
                                    + h.slash + h.rest_prefix
                                    + h.slash + customer.id.str()) // getId()

        ctx.res.set_status(.created) // <== HTTP 201 Created

        return ctx.json(customer)
    } else if (method == .get) || (method == .head) {
        // Retrieving all customer profiles from the database.
        customers := c.get_customers(app.dbg, mut app.l, app.cnx)

        return ctx.json(customers)
    } else {
        // Methods POST, PATCH, DELETE, OPTIONS, and TRACE go here.
        // For any other method veb will automatically respond
        // with the HTTP 404 Not Found status code.
        ctx.res.header.add(.allow, h.hdr_allow_1)
        ctx.res.set_status(.method_not_allowed) //< HTTP 405 Method Not Allowed

        return ctx.json(Error_{
            error: h.err_req_method_not_allowed + h.hdr_allow_1
        })
    }
}

// add_contact The `PUT /v1/customers/contacts` endpoint.
//
// Creates a new contact for a given customer (puts a contact
// regarding a given customer to the database).
//
// The request body is defined exactly in the form
// as `{"customer_id":"{customer_id}","contact":"{customer_contact}"}`.
// It should be passed with the accompanied request header `content-type`
// just like the following:
//
// `-H 'content-type: application/json' -d '{"customer_id":"{customer_id}","contact":"{customer_contact}"}'`
//
// `{customer_id}` is the customer ID used to associate a newly created contact
// with this customer.
//
// `{customer_contact}` is a newly created contact (phone or email).
//
// @param `ctx` The struct containing an HTTP request/response pair.
//
// @returns The `Result` struct with the `201 Created` HTTP status code,
//          the `Location` response header (among others), and the response
//          body in JSON representation, containing details of a newly created
//          customer contact (phone or email).
//          May return client or server error depending on incoming request.
@['/v1/customers/contacts'; put;
    head; get; post; patch; delete; options; trace]
pub fn (mut app CustomersApiLiteApp) add_contact(mut ctx RequestContext)
    veb.Result {

    method := ctx.req.method

    h.dbg_(app.dbg, mut app.l, h.o_bracket + method.str() + h.c_bracket)

    if method == .put {
        // Creating a new contact (putting a contact regarding a given customer
        // to the database).
        customer_id, contact_type, contact := c.put_contact(app.dbg, mut app.l,
            app.cnx, ctx.req.data)

        // Validating the request payload through the return value
        // ("empty contact") from controller.
        if (contact.contact == h.space) && (contact.customer_id == 0.str()) {
            ctx.res.set_status(.bad_request)

            return ctx.json(Error_{ error: h.err_req_malformed })
        } else if (contact.contact.len == 0) && (contact.customer_id.len == 0){
            ctx.res.set_status(.not_found)

            return ctx.json(Error_{ error: h.err_req_not_found_1 })
        }

        ctx.res.header.add(.location, h.slash + h.rest_version
                                    + h.slash + h.rest_prefix
                                    + h.slash + customer_id
                                    + h.slash + h.rest_contacts
                                    + h.slash + contact_type)

        ctx.res.set_status(.created)

        return ctx.json(contact)
    } else {
        ctx.res.header.add(.allow, h.hdr_allow_2)
        ctx.res.set_status(.method_not_allowed)

        return ctx.json(Error_{
            error: h.err_req_method_not_allowed + h.hdr_allow_2
        })
    }
}

// get_customer The `GET /v1/customers/{customer_id}` endpoint.
//
// Retrieves profile details for a given customer from the database.
//
// @param `ctx`         The struct containing an HTTP request/response pair.
// @param `customer_id` The customer ID used to retrieve customer profile data.
//
// @returns The `Result` struct with the `200 OK` HTTP status code, containing
//          profile details for a given customer (in the response body
//          in JSON representation).
//          May return client or server error depending on incoming request.
@['/v1/customers/:customer_id'; get; head;
    put; post; patch; delete; options; trace]
pub fn (mut app CustomersApiLiteApp) get_customer(mut ctx RequestContext,
    customer_id string) veb.Result {

    method := ctx.req.method

    h.dbg_(app.dbg, mut app.l, h.o_bracket + method.str() + h.c_bracket)

    if (method == .get) || (method == .head) {
        // Validating the request path variable.
        strconv.atoi(customer_id) or {
            ctx.res.set_status(.bad_request)

            return ctx.json(Error_{ error: h.err_req_malformed })
        }

        // Retrieving profile details for a given customer from the database.
        customer := c.get_customer(app.dbg, mut app.l, app.cnx, customer_id)

        if customer.id == 0 {
            ctx.res.set_status(.not_found)

            return ctx.json(Error_{ error: h.err_req_not_found_1 })
        }

        return ctx.json(customer)
    } else {
        ctx.res.header.add(.allow, h.hdr_allow_3)
        ctx.res.set_status(.method_not_allowed)

        return ctx.json(Error_{
            error: h.err_req_method_not_allowed + h.hdr_allow_3
        })
    }
}

// list_contacts The `GET /v1/customers/{customer_id}/contacts` endpoint.
//
// Retrieves from the database and lists all contacts
// associated with a given customer.
//
// @param `ctx`         The struct containing an HTTP request/response pair.
// @param `customer_id` The customer ID used to retrieve contacts
//                      which belong to this customer.
//
// @returns The `Result` struct with the `200 OK` HTTP status code
//          and the response body in JSON representation,
//          containing a list of all contacts associated with a given customer.
//          May return client or server error depending on incoming request.
@['/v1/customers/:customer_id/contacts'; get; head;
    put; post; patch; delete; options; trace]
pub fn (mut app CustomersApiLiteApp) list_contacts(mut ctx RequestContext,
    customer_id string) veb.Result {

    method := ctx.req.method

    h.dbg_(app.dbg, mut app.l, h.o_bracket + method.str() + h.c_bracket)

    if (method == .get) || (method == .head) {
        // Validating the request path variable.
        strconv.atoi(customer_id) or {
            ctx.res.set_status(.bad_request)

            return ctx.json(Error_{ error: h.err_req_malformed })
        }

        // Retrieving all contacts associated with a given customer
        // from the database.
        contacts := c.get_contacts(app.dbg, mut app.l, app.cnx, customer_id)

        if contacts.len == 0 {
            ctx.res.set_status(.not_found)

            return ctx.json(Error_{ error: h.err_req_not_found_2 })
        }

        return ctx.json(contacts)
    } else {
        ctx.res.header.add(.allow, h.hdr_allow_3)
        ctx.res.set_status(.method_not_allowed)

        return ctx.json(Error_{
            error: h.err_req_method_not_allowed + h.hdr_allow_3
        })
    }
}

// list_contacts_by_type The
// `GET /v1/customers/{customer_id}/contacts/{contact_type}` endpoint.
//
// Retrieves from the database and lists all contacts of a given type
// associated with a given customer.
//
// @param `ctx`          The struct containing an HTTP request/response pair.
// @param `customer_id`  The customer ID used to retrieve contacts
//                       which belong to this customer.
// @param `contact_type` The particular type of contacts to retrieve
//                       (e.g. phone, email, postal address, etc.).
//
// @returns The `Result` struct with the `200 OK` HTTP status code
//          and the response body in JSON representation,
//          containing a list of all contacts of a given type
//          associated with a given customer.
//          May return client or server error depending on incoming request.
@['/v1/customers/:customer_id/contacts/:contact_type'; get; head;
    put; post; patch; delete; options; trace]
pub fn (mut app CustomersApiLiteApp) list_contacts_by_type(
    mut ctx          RequestContext,
        customer_id  string,
        contact_type string) veb.Result {

    method := ctx.req.method

    h.dbg_(app.dbg, mut app.l, h.o_bracket + method.str() + h.c_bracket)

    if (method == .get) || (method == .head) {
        // Validating the request path variable.
        strconv.atoi(customer_id) or {
            ctx.res.set_status(.bad_request)

            return ctx.json(Error_{ error: h.err_req_malformed })
        }

        // Retrieving all contacts of a given type associated
        // with a given customer from the database.
        contacts := c.get_contacts_by_type(app.dbg, mut app.l, app.cnx,
            customer_id, contact_type.to_lower_ascii())

        if contacts.len == 0 {
            ctx.res.set_status(.not_found)

            return ctx.json(Error_{ error: h.err_req_not_found_3 })
        }

        return ctx.json(contacts)
    } else {
        ctx.res.header.add(.allow, h.hdr_allow_3)
        ctx.res.set_status(.method_not_allowed)

        return ctx.json(Error_{
            error: h.err_req_method_not_allowed + h.hdr_allow_3
        })
    }
}

// vim:set nu et ts=4 sw=4:
