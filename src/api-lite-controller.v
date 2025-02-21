/*
 * src/api-lite-controller.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.10
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

import helper as h

// list_customers_ Helper function for the `list_customers()` endpoint.
pub fn list_customers_(dbg bool, mut l log.Log) {
    h.dbg_(dbg, mut l, h.o_bracket + '${dbg}' + h.c_bracket)
}

// vim:set nu et ts=4 sw=4:
