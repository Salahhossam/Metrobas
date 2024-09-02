package com.transportation.metrobas.user;

import com.transportation.metrobas.enums.Gender;

public class UserDto {
    private int userId;

    private String email;

    private String phone;

    private String userName;

    private int age;
    private Gender gender;

    public UserDto(int userId, String email, String phone, String userName, int age, Gender gender) {
        this.userId = userId;
        this.email = email;
        this.phone = phone;
        this.userName = userName;
        this.age = age;
        this.gender = gender;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public Gender getGender() {
        return gender;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }
}
