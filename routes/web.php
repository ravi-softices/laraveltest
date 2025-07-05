<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/', function (Request $request) {
    $ip = $request->ip();
    var_dump($ip);
        $userAgent = $request->userAgent();
        var_dump($userAgent);
    // return view('welcome');
});

