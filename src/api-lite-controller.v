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
import json
import strconv

import helper as h
import model  as m

struct Logger_ {
    logging string
    enabled bool
}

// Customer The struct defining the Customer entity.
pub struct Customer {
    name string
pub:
    id   int
}

// Contact The struct defining the Contact entity.
pub struct Contact {
    contact string
}

// common_ctrl_hlpr_ Common controller helper function.
pub fn common_ctrl_hlpr_(dbg bool) &Logger_ {
    logger := &Logger_{
        logging: 'debug'
        enabled: dbg
    }

    return logger
}

// put_customer Puts customer data to the database.
//              Used by the `add_list_customers()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns A new Customer entity instance of a newly created customer.
pub fn put_customer(dbg bool, mut l log.Log, cnx sqlite.DB, payload string)
    Customer {

    customer := json.decode(Customer, payload) or { panic(err) }

    h.dbg_(dbg, mut l, h.o_bracket + customer.name + h.c_bracket)

    cnx.exec_none(m.sql_put_customer[0] + customer.name
                + m.sql_put_customer[1])

    customers := cnx.exec(m.sql_get_all_customers + m.sql_desc_limit_1)
        or { panic(err) }

    cust := Customer{
        id:   strconv.atoi(customers[0].vals[0]) or { panic(err) }
        name:              customers[0].vals[1]
    }

    h.dbg_(dbg, mut l, h.o_bracket + cust.id.str() // getId()
                     + h.v_bar     + cust.name     // getName()
                     + h.c_bracket)

    return cust
}

// put_contact Puts a contact regarding a given customer to the database.
//             Used by the `add_contact()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns A new Contact entity instance of a newly created customer contact.
pub fn put_contact(dbg bool, mut l log.Log, cnx sqlite.DB, payload string)
    Contact {

    h.dbg_(dbg, mut l, h.o_bracket + '${payload}' + h.c_bracket)

    cont := Contact{}

    return cont
}

// get_customers Retrieves all customer profiles from the database.
//               Used by the `add_list_customers()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns An array of Customer entities retrieved from the database.
pub fn get_customers(dbg bool, mut l log.Log, cnx sqlite.DB) []Customer {
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

    h.dbg_(dbg, mut l, h.cust_id + h.equals + customer_id)

    customers := cnx.exec_param(m.sql_get_customer_by_id, customer_id)
        or { panic(err) }

    cust := Customer{
        id:   strconv.atoi(customers[0].vals[0]) or { panic(err) }
        name:              customers[0].vals[1]
    }

    h.dbg_(dbg, mut l, h.o_bracket + cust.id.str() // getId()
                     + h.v_bar     + cust.name     // getName()
                     + h.c_bracket)

    return cust
}

// get_contacts Retrieves all contacts associated with a given customer
//              from the database. Used by the `list_contacts()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns An array of Contact entities retrieved from the database.
pub fn get_contacts(dbg bool, mut l log.Log, cnx sqlite.DB, customer_id string
    ) []Contact {

    h.dbg_(dbg, mut l, h.cust_id + h.equals + customer_id)

    contacts := cnx.exec_param_many(m.sql_get_all_contacts, [
        customer_id, // <== For retrieving phones.
        customer_id  // <== For retrieving emails.
    ]) or { panic(err) }

    mut conts := []Contact{}

    for contact in contacts {
        conts << Contact{
            contact: contact.vals[0]
        }
    }

    h.dbg_(dbg, mut l, h.o_bracket + conts[0].contact // getContact()
                     + h.c_bracket)

    return conts
}

// get_contacts_by_type Retrieves all contacts of a given type associated
//                      with a given customer from the database.
//                      Used by the `list_contacts_by_type()` endpoint.
//
// @param `dbg` The debug logging enabler.
// @param `l`   The main logger of the daemon.
// @param `cnx` The connection to the database.
//
// @returns An array of Contact entities retrieved from the database.
pub fn get_contacts_by_type(dbg bool, mut l log.Log, cnx sqlite.DB,
    customer_id  string,
    contact_type string) []Contact {

    h.dbg_(dbg, mut l, h.cust_id   + h.equals + customer_id + h.space + h.v_bar
           + h.space + h.cont_type + h.equals + contact_type)

    mut sql_query := m.sql_get_contacts_by_type[2]

    if (contact_type == h.phone)
        || (contact_type == h.phone.to_upper_ascii()) {

        sql_query = m.sql_get_contacts_by_type[0]
    } else if (contact_type == h.email)
        || (contact_type == h.email.to_upper_ascii()) {

        sql_query = m.sql_get_contacts_by_type[1]
    }

    contacts  := cnx.exec_param(sql_query, customer_id) or { panic(err) }
    mut conts := []Contact{}

    for contact in contacts {
        conts << Contact{
            contact: contact.vals[0]
        }
    }

    h.dbg_(dbg, mut l, h.o_bracket + conts[0].contact // getContact()
                     + h.c_bracket)

    return conts
}

// vim:set nu et ts=4 sw=4:
