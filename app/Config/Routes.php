<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */
$routes->get('/', 'Auth::index');
$routes->post('login', 'Auth::login', ['filter' => 'csrf']);
$routes->post('logout', 'Auth::logout', ['filter' => 'csrf']);
