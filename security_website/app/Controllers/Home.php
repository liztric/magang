<?php

namespace App\Controllers;

class Home extends BaseController
{
    public function index(): string
    {
        return view('index');
    }
    public function register(): string
    {
        return view('register');
    }
    public function daftaruser(): string
    {
        return view('daftaruser');
}
}