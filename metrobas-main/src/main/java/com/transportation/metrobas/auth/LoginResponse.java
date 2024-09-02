package com.transportation.metrobas.auth;

import com.transportation.metrobas.user.UserDto;

public class LoginResponse {

    private String token;

    private UserDto userDto;

    public LoginResponse() {
    }

    public LoginResponse(String token, UserDto userDto) {
        this.token = token;
        this.userDto = userDto;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public UserDto getUserDto() {
        return userDto;
    }

    public void setUserDto(UserDto userDto) {
        this.userDto = userDto;
    }
}
