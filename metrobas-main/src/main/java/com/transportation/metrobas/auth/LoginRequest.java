package com.transportation.metrobas.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

public class LoginRequest {

    @NotEmpty(message = "userName or email cannot be empty")
    private String userName;

    @NotEmpty(message = "Password cannot be empty")
    @Size(min = 8, message = "Password must be at least 8 characters long")
    private String password;

    public LoginRequest() {
    }


    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
