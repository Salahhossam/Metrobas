package com.transportation.metrobas.auth;

import com.transportation.metrobas.enums.Gender;
import jakarta.validation.constraints.*;

public class RegisterRequest {
    @Email(message = "Please provide a valid email address")
    private String email;

    @NotEmpty(message = "first name cannot be empty")
    private String firstName;

    @NotEmpty(message = "last name cannot be empty")
    private String lastName;

    @NotEmpty(message = "Password cannot be empty")
    @Size(min = 8, message = "Password must be at least 8 characters long")
    private String password;

    @NotEmpty(message = "Confirm Password cannot be empty")
    @Size(min = 8, message = "Confirm Password must be at least 8 characters long")
    private String confirmPassword;

    @NotEmpty(message = "Username cannot be empty")
    @Size(min = 5, message = "Username must be at least 5 characters long")
    private String userName;

    @Pattern(regexp = "\\d{11}", message = "Phone number must be 11 digits")
    private String phone;

    @NotNull(message = "Age cannot be empty")
    @Min(6)
    @Max(100)
    private Integer age;

    @NotNull(message = "Gender cannot be empty")

    private Gender gender;

    public RegisterRequest() {
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getConfirmPassword() {
        return confirmPassword;
    }

    public void setConfirmPassword(String confirmPassword) {
        this.confirmPassword = confirmPassword;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
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
