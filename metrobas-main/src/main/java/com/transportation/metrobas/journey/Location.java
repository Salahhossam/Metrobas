package com.transportation.metrobas.journey;

import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class Location {

    @NotNull(message = "Longitude cannot be null")
    private double longitude;

    @NotNull(message = "Latitude cannot be null")
    private double latitude;

    public Location() {
    }


    public Location(double longitude, double latitude) {
        this.longitude = longitude;
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }
}
