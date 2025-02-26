/*
 * src/api-lite-controller.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.20
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The controller module of the daemon ----------------------------------------

module controller

import log
import db.sqlite
import strconv

import helper as h
import model  as m

struct Logger_ {
    logging string
    enabled bool
}

// Customer The struct defining the Customer entity.
pub struct Customer {
    id   int
    name string
}

// Contact The struct defining the Contact entity.
pub struct Contact {
    // TODO: Declare fields.
}

// common_ctrl_hlpr_ Common controller helper function.
pub fn common_ctrl_hlpr_(dbg bool) &Logger_ {
    logger := &Logger_{
        logging: 'debug'
        enabled: dbg
    }

    return logger
}

// add_customer Puts customer data to the database.
//              Used by the `add_list_customers()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns A new Customer entity instance of a newly created customer.
pub fn add_customer(dbg bool, mut l log.Log, cnx sqlite.DB, payload string)
    Customer {

    h.dbg_(dbg, mut l, h.o_bracket + '${payload}' + h.c_bracket)

    cust := Customer{}

    return cust
}

// add_contact Puts a contact regarding a given customer to the database.
//             Used by the `add_contact()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns A new Contact entity instance of a newly created customer contact.
pub fn add_contact(dbg bool, mut l log.Log, cnx sqlite.DB, payload string)
    Contact {

    h.dbg_(dbg, mut l, h.o_bracket + '${payload}' + h.c_bracket)

    cont := Contact{}

    return cont
}

// list_customers Retrieves all customer profiles from the database.
//                Used by the `add_list_customers()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns An array of Customer entities retrieved from the database.
pub fn list_customers(dbg bool, mut l log.Log, cnx sqlite.DB) []Customer {
    customers := cnx.exec(m.sql_get_all_customers) or { panic(err) }
    mut custs := []Customer{}

    for customer in customers {
        custs << Customer{
            id:   strconv.atoi(customer.vals[0]) or { panic(err) }
            name:              customer.vals[1]
        }
    }

    h.dbg_(dbg, mut l, h.o_bracket + custs[0].id.str() // getId()
                     + h.v_bar     + custs[0].name     // getName()
                     + h.c_bracket)

    return custs
}

// get_customer Retrieves profile details for a given customer
//              from the database. Used by the `get_customer()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns A Customer entity instance of a given customer.
pub fn get_customer(dbg bool, mut l log.Log, cnx sqlite.DB, customer_id string)
    Customer {

    h.dbg_(dbg, mut l, h.o_bracket + '${customer_id}' + h.c_bracket)

    cust := Customer{}

    return cust
}

// list_contacts Retrieves all contacts associated with a given customer
//               from the database. Used by the `list_contacts()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns An array of Contact entities retrieved from the database.
pub fn list_contacts(dbg bool, mut l log.Log, cnx sqlite.DB, customer_id string
    ) []Contact {

    h.dbg_(dbg, mut l, h.o_bracket + '${customer_id}' + h.c_bracket)

    conts := []Contact{}

    return conts
}

// list_contacts_by_type Retrieves all contacts of a given type associated
//                       with a given customer from the database.
//                       Used by the `list_contacts_by_type()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns An array of Contact entities retrieved from the database.
pub fn list_contacts_by_type(dbg bool, mut l log.Log, cnx sqlite.DB,
    customer_id  string,
    contact_type string) []Contact {

    h.dbg_(dbg, mut l, h.o_bracket + '${customer_id}'
                     + h.v_bar     + '${contact_type}'
                     + h.c_bracket)

    conts := []Contact{}

    return conts
}

// vim:set nu et ts=4 sw=4:
