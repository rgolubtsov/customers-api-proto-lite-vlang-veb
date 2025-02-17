/*
 * src/api-lite-core.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.1
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The main module of the daemon and the entry point --------------------------

module main

//import vweb
//import databases
//import os

//const port = 8765

/*struct App {
    vweb.Context
}*/

/*pub fn (app App) before_request() {
    println('[web] before_request: ${app.req.method} ${app.req.url}')
}*/

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    println('[Customers API Lite]')

//  mut db := databases.create_db_connection() or { panic(err) }

/*  sql db {
        create table User
        create table Product
    } or { panic('error on create table: ${err}') }*/

//  db.close() or { panic(err) }

/*  mut app := &App{}
    app.serve_static('/favicon.ico', 'src/assets/favicon.ico')
    // makes all static files available.
    app.mount_static_folder_at(os.resource_abs_path('.'), '/')*/

//  vweb.run(app, port)
}

/*pub fn (mut app App) index() vweb.Result {
    title := 'vweb app'

    return $vweb.html()
}*/

// vim:set nu et ts=4 sw=4:
