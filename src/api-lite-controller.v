/*
 * src/api-lite-controller.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.2.1
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
import regex

import helper as h
import model  as m

// Customer The struct defining the Customer entity.
pub struct Customer {
pub:
    id   int
    name string
}

// Contact The struct defining the Contact entity.
pub struct Contact {
pub:
    contact     string
    customer_id string @[omitempty]
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

    customer := json.decode(Customer, payload) or {
        // Returning an "empty customer" in case of malformed request payload.
        return Customer{
            id:   0
            name: h.space
        }
    }

    h.dbg_(dbg, mut l, h.o_bracket + customer.name + h.c_bracket)

    cnx.exec_none(m.sql_put_customer[0] + customer.name
                + m.sql_put_customer[1])

    customers := cnx.exec(m.sql_get_all_customers + m.sql_desc_limit_1)
        or { panic(err) }

    cust := Customer{
        id:   strconv.atoi(customers[0].vals[0]) or { 1 }
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
    (string, string, Contact) {

    contact := json.decode(Contact, payload) or {
        // Returning an "empty contact" in case of malformed request payload.
        return h.space,  h.space, Contact{
            contact:     h.space
            customer_id: 0.str()
        }
    }

    h.dbg_(dbg, mut l, h.cust_id + h.equals + contact.customer_id)
    h.dbg_(dbg, mut l, h.o_bracket + contact.contact + h.c_bracket)

    // Parsing and validating a customer contact: phone or email.
    contact_type := parse_contact_(contact.contact)

    if contact_type == h.space {
        // Returning an "empty contact" when a contact given
        // in the request payload neither phone nor email.
        return h.space,  h.space, Contact{
            contact:     h.space
            customer_id: 0.str()
        }
    }

    mut sql_query := [m.sql_put_contact[1][0],
                      m.sql_put_contact[1][1],
                      m.sql_put_contact[1][2]]

    if (contact_type == h.phone)
        || (contact_type == h.phone.to_upper_ascii()) {

        sql_query = [m.sql_put_contact[0][0],
                     m.sql_put_contact[0][1],
                     m.sql_put_contact[0][2]]
    } else if (contact_type == h.email)
        || (contact_type == h.email.to_upper_ascii()) {

        sql_query = [m.sql_put_contact[1][0],
                     m.sql_put_contact[1][1],
                     m.sql_put_contact[1][2]]
    }

    cnx.exec_none(sql_query[0] + contact.contact
                + sql_query[1] + contact.customer_id
                + sql_query[2])

    mut sql_query_ := m.sql_get_contacts_by_type[2]

    if (contact_type == h.phone)
        || (contact_type == h.phone.to_upper_ascii()) {

        sql_query_ = m.sql_get_contacts_by_type[0]
                   + m.sql_order_contacts_by_id[0]
    } else if (contact_type == h.email)
        || (contact_type == h.email.to_upper_ascii()) {

        sql_query_ = m.sql_get_contacts_by_type[1]
                   + m.sql_order_contacts_by_id[1]
    }

    contacts := cnx.exec_param(sql_query_ + m.sql_desc_limit_1,
        contact.customer_id) or { panic(err) }

    // Returning an "empty contact" when there is no customer
    // with requested ID found.
    if contacts.len == 0 {
        return contact.customer_id, contact_type, Contact{}
    }

    cont := Contact{
        contact: contacts[0].vals[0]
    }

    h.dbg_(dbg, mut l, h.o_bracket + contact_type
                     + h.v_bar     + cont.contact // getContact()
                     + h.c_bracket)

    return contact.customer_id, contact_type, cont
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
            id:   strconv.atoi(customer.vals[0]) or { 1 }
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

    // Validating the request path variable (unlikely to reach here
    // in case it is actually malformed).
    cust_id := strconv.atoi(customer_id) or { 1 }

    customers := cnx.exec_param(m.sql_get_customer_by_id, cust_id.str())
        or { panic(err) }

    // Returning an "empty customer" when there is no customer with such ID.
    if customers.len == 0 { return Customer{} }

    cust := Customer{
        id:   strconv.atoi(customers[0].vals[0]) or { 1 }
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

    // Validating the request path variable (unlikely to reach here
    // in case it is actually malformed).
    cust_id := strconv.atoi(customer_id) or { 1 }

    contacts := cnx.exec_param_many(m.sql_get_all_contacts, [
        cust_id.str(), // <== For retrieving phones.
        cust_id.str()  // <== For retrieving emails.
    ]) or { panic(err) }

    mut conts := []Contact{}

    for contact in contacts {
        conts << Contact{
            contact: contact.vals[0]
        }
    }

    // Returning no contacts when there are no contacts belonging
    // to a given customer exist, or there is no customer with such ID.
    if conts.len == 0 { return conts }

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

    // Validating the request path variable (unlikely to reach here
    // in case it is actually malformed).
    cust_id := strconv.atoi(customer_id) or { 1 }

    mut sql_query := m.sql_get_contacts_by_type[2]

    if (contact_type == h.phone)
        || (contact_type == h.phone.to_upper_ascii()) {

        sql_query = m.sql_get_contacts_by_type[0]
    } else if (contact_type == h.email)
        || (contact_type == h.email.to_upper_ascii()) {

        sql_query = m.sql_get_contacts_by_type[1]
    }

    contacts  := cnx.exec_param(sql_query, cust_id.str()) or { panic(err) }
    mut conts := []Contact{}

    for contact in contacts {
        conts << Contact{
            contact: contact.vals[0]
        }
    }

    // Returning no contacts when there are no contacts of a given type
    // belonging to a given customer exist, or there is no customer
    // with such ID.
    if conts.len == 0 { return conts }

    h.dbg_(dbg, mut l, h.o_bracket + conts[0].contact // getContact()
                     + h.c_bracket)

    return conts
}

// parse_contact_ Helper func. Used to parse and validate a customer contact.
//                             Returns the type of contact: phone or email.
fn parse_contact_(contact string) string {
    phone_regex := regex.regex_opt(h.phone_regex) or { panic(err) }
    email_regex := regex.regex_opt(h.email_regex) or { panic(err) }

         if phone_regex.matches_string(contact) { return h.phone }
    else if email_regex.matches_string(contact) { return h.email }

    return h.space
}

// vim:set nu et ts=4 sw=4:
