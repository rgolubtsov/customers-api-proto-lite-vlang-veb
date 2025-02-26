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

// common_ctrl_hlpr_ Common controller helper function.
pub fn common_ctrl_hlpr_(dbg bool) &Logger_ {
    logger := &Logger_{
        logging: 'debug'
        enabled: dbg
    }

    return logger
}

// add_customer_ Helper function for the `add_customer()` endpoint.
pub fn add_customer_(dbg bool, mut l log.Log, payload string) {
    h.dbg_(dbg, mut l, h.o_bracket + '${payload}' + h.c_bracket)
}

// add_contact_ Helper function for the `add_contact()` endpoint.
pub fn add_contact_(dbg bool, mut l log.Log, payload string) {
    h.dbg_(dbg, mut l, h.o_bracket + '${payload}' + h.c_bracket)
}

// list_customers_ Helper function for the `list_customers()` endpoint.
pub fn list_customers_(dbg bool, mut l log.Log, cnx sqlite.DB) []Customer {
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

// get_customer_ Helper function for the `get_customer()` endpoint.
pub fn get_customer_(dbg bool, mut l log.Log) {
    h.dbg_(dbg, mut l, h.o_bracket + '${dbg}' + h.c_bracket)
}

// list_contacts_ Helper function for the `list_contacts()` endpoint.
pub fn list_contacts_(dbg bool, mut l log.Log) {
    h.dbg_(dbg, mut l, h.o_bracket + '${dbg}' + h.c_bracket)
}

// list_contacts_by_type_ Helper function for the `list_contacts_by_type()`
// endpoint.
pub fn list_contacts_by_type_(dbg bool, mut l log.Log) {
    h.dbg_(dbg, mut l, h.o_bracket + '${dbg}' + h.c_bracket)
}

// vim:set nu et ts=4 sw=4:
