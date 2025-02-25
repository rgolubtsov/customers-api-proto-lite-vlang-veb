/*
 * src/api-lite-model.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.20
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The model module of the daemon ---------------------------------------------

module model

// sql_get_all_customers The SQL query for retrieving all customer profiles.
//
// Used by the `GET /v1/customers` REST endpoint.
const sql_get_all_customers
    = "select id ," // as 'Customer ID',"
    + "       name" // as 'Customer Name'"
    + " from"
    + "       customers"
    + " order by"
    + "       id"

// sql_get_customer_by_id The SQL query for retrieving profile details
//                        for a given customer.
//
// Used by the `GET /v1/customers/{customer_id}` REST endpoint.
const sql_get_customer_by_id
    = "select id ," // as 'Customer ID',"
    + "       name" // as 'Customer Name'"
    + " from"
    + "       customers"
    + " where"
    + "      (id = ?)"

// sql_get_all_contacts The SQL query for retrieving all contacts
//                      for a given customer.
//
// Used by the `GET /v1/customers/{customer_id}/contacts` REST endpoint.
const sql_get_all_contacts
    = "select phones.contact" // as 'Phone(s)'"
    + " from"
    + "       contact_phones phones,"
    + "       customers      cust"
    + " where"
    + "      (cust.id = phones.customer_id) and"
    + "      (cust.id =                  ?)"
    + " union "
    + "select emails.contact" // as 'Email(s)'"
    + " from"
    + "       contact_emails emails,"
    + "       customers      cust"
    + " where"
    + "      (cust.id = emails.customer_id) and"
    + "      (cust.id =                  ?)"

// sql_get_contacts_by_type The SQL queries for retrieving all contacts
//                          of a given type for a given customer.
//
// Used by the `GET /v1/customers/{customer_id}/contacts/{contact_type}`
// REST endpoint.
const sql_get_contacts_by_type
    =["select phones.contact" // as 'Phone(s)'"
    + " from"
    + "       contact_phones phones,"
    + "       customers      cust"
    + " where"
    + "      (cust.id = phones.customer_id) and"
    + "      (cust.id =                  ?)",
      "select emails.contact" // as 'Email(s)'"
    + " from"
    + "       contact_emails emails,"
    + "       customers      cust"
    + " where"
    + "      (cust.id = emails.customer_id) and"
    + "      (cust.id =                  ?)",
      "select name from customers where (id = ?)"]

// sql_order_contacts_by_id The intermediate part of an SQL query,
//                          used to order contact records by ID.
const sql_order_contacts_by_id
    =[" order by phones.id",
      " order by emails.id"]

// sql_desc_limit_1 The terminating part of an SQL query,
//                  used to retrieve the last record created.
const sql_desc_limit_1 = " desc limit 1"

// vim:set nu et ts=4 sw=4:
