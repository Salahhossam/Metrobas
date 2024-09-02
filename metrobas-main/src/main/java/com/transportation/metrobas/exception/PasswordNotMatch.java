package com.transportation.metrobas.exception;

public class PasswordNotMatch extends RuntimeException{
    public PasswordNotMatch(String message) {
        super(message);
    }
}
