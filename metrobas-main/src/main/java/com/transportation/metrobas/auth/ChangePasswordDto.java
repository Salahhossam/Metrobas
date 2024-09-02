package com.transportation.metrobas.auth;

import jakarta.validation.constraints.NotEmpty;

public class ChangePasswordDto {
    @NotEmpty(message = "current password cannot be empty")
    private String currentPassword;

    @NotEmpty(message = "new password cannot be empty")
    private String newPassword;

    @NotEmpty(message = "confirm password cannot be empty")
    private String confirmNewPassword;


    public ChangePasswordDto() {
    }

    public ChangePasswordDto(String currentPassword, String newPassword, String confirmNewPassword) {
        this.currentPassword = currentPassword;
        this.newPassword = newPassword;
        this.confirmNewPassword = confirmNewPassword;
    }

    public String getCurrentPassword() {
        return currentPassword;
    }

    public void setCurrentPassword(String currentPassword) {
        this.currentPassword = currentPassword;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }

    public String getConfirmNewPassword() {
        return confirmNewPassword;
    }

    public void setConfirmNewPassword(String confirmNewPassword) {
        this.confirmNewPassword = confirmNewPassword;
    }
}
