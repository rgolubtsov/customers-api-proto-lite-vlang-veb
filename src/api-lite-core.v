/*
 * src/api-lite-core.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.10
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

import vseryakov.syslog as s

import helper     as h
import controller as c

// CustomersApiLiteApp The main web app struct containing arbitrary data
// that are accessible by all endpoints and shared between different routes.
pub struct CustomersApiLiteApp {
    dbg bool
mut:
    l   log.Log
}

// RequestContext The struct containing data that are specific to each request.
// It also holds a standard HTTP request/response pair.
pub struct RequestContext {
    veb.Context
}

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    // Getting the daemon settings.
    settings := h.get_settings_()

    daemon_name := settings.value(h.daemon_name_).string()

    // Getting the port number used to run the inbuilt web server.
    server_port := settings.value(h.server_port_).int()

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

    // Opening the system logger.
    // Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
    s.open(os.base(os.args[0]), s.log_cons | s.log_pid, s.log_daemon)

//  if dbg { l.set_level(.debug) }

    l.info(h.msg_server_started + '${server_port}')
    s.info(h.msg_server_started + '${server_port}')

    h.dbg_(dbg, mut l, h.o_bracket + daemon_name + h.c_bracket)

    mut app := &CustomersApiLiteApp{
        dbg: dbg
        l:   l
    }

    // Trying to start up the inbuilt web server.
    veb.run_at[CustomersApiLiteApp, RequestContext](mut app, port: server_port,
        show_startup_message: false) or {
            h.cleanup_(mut l)
            panic(err)
        }
}

// add_customer The `PUT /v1/customers` endpoint.
//
// Creates a new customer (puts customer data to the database).
//
// The request body is defined exactly in the form
// as `{"name":"{customer_name}"}`. It should be passed with the accompanied
// request header `content-type` just like the following:
//
// `-H 'content-type: application/json' -d '{"name":"{customer_name}"}'`
//
// `{customer_name}` is a name assigned to a newly created customer.
//
// @returns The `Result` struct with the `201 Created` HTTP status code,
//          the `Location` response header (among others), and the response
//          body in JSON representation, containing profile details
//          of a newly created customer.
//          May return client or server error depending on incoming request.
@['/v1/customers'; put]
pub fn (mut app CustomersApiLiteApp) add_customer(mut ctx RequestContext)
    veb.Result {

    payload := ctx.req.data

    c.add_customer_(app.dbg, mut app.l, payload)

    logger := c.common_ctrl_hlpr_(app.dbg)

    return ctx.json(logger)
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
// @returns The `Result` struct with the `201 Created` HTTP status code,
//          the `Location` response header (among others), and the response
//          body in JSON representation, containing details of a newly created
//          customer contact (phone or email).
//          May return client or server error depending on incoming request.
@['/v1/customers/contacts'; put]
pub fn (mut app CustomersApiLiteApp) add_contact(mut ctx RequestContext)
    veb.Result {

    payload := ctx.req.data

    c.add_contact_(app.dbg, mut app.l, payload)

    logger := c.common_ctrl_hlpr_(app.dbg)

    return ctx.json(logger)
}

// list_customers The `GET /v1/customers` endpoint.
//
// Retrieves from the database and lists all customer profiles.
//
// @returns The `Result` struct with the `200 OK` HTTP status code
//          and the response body in JSON representation,
//          containing a list of all customer profiles.
//          May return client or server error depending on incoming request.
@['/v1/customers']
pub fn (mut app CustomersApiLiteApp) list_customers(mut ctx RequestContext)
    veb.Result {

    c.list_customers_(app.dbg, mut app.l)

    logger := c.common_ctrl_hlpr_(app.dbg)

    return ctx.json(logger)
}

// get_customer The `GET /v1/customers/{customer_id}` endpoint.
//
// Retrieves profile details for a given customer from the database.
//
// @param `customer_id` The customer ID used to retrieve customer profile data.
//
// @returns The `Result` struct with a specific HTTP status code provided,
//          containing profile details for a given customer
//          (in the response body in JSON representation).
@['/v1/customers/:customer_id']
pub fn (mut app CustomersApiLiteApp) get_customer(mut ctx RequestContext,
    customer_id string) veb.Result {

    c.get_customer_(app.dbg, mut app.l)

    logger := c.common_ctrl_hlpr_(app.dbg)

    return ctx.json(logger)
}

// list_contacts The `GET /v1/customers/{customer_id}/contacts` endpoint.
//
// Retrieves from the database and lists all contacts
// associated with a given customer.
//
// @param `customer_id` The customer ID used to retrieve contacts
//                      which belong to this customer.
//
// @returns The `Result` struct with the `200 OK` HTTP status code
//          and the response body in JSON representation,
//          containing a list of all contacts associated with a given customer.
//          May return client or server error depending on incoming request.
@['/v1/customers/:customer_id/contacts']
pub fn (mut app CustomersApiLiteApp) list_contacts(mut ctx RequestContext,
    customer_id string) veb.Result {

    c.list_contacts_(app.dbg, mut app.l)

    logger := c.common_ctrl_hlpr_(app.dbg)

    return ctx.json(logger)
}

// list_contacts_by_type The
// `GET /v1/customers/{customer_id}/contacts/{contact_type}` endpoint.
//
// Retrieves from the database and lists all contacts of a given type
// associated with a given customer.
//
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
@['/v1/customers/:customer_id/contacts/:contact_type']
pub fn (mut app CustomersApiLiteApp) list_contacts_by_type(
    mut ctx          RequestContext,
        customer_id  string,
        contact_type string) veb.Result {

    c.list_contacts_by_type_(app.dbg, mut app.l)

    logger := c.common_ctrl_hlpr_(app.dbg)

    return ctx.json(logger)
}

// vim:set nu et ts=4 sw=4:
