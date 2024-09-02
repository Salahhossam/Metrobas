package com.transportation.metrobas.savedplaces;

import jakarta.persistence.Column;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class SaveSavedPlaceDto {

    @NotBlank(message = "please enter valid name of saved place")
    private String name;

    @NotBlank(message = "please enter valid label of saved place")
    private String label;

    @NotNull(message = "Latitude cannot be null")
    private double stopLat;

    @NotNull(message = "Longitude cannot be null")
    private double stopLon;

    public SaveSavedPlaceDto() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getStopLat() {
        return stopLat;
    }

    public void setStopLat(double stopLat) {
        this.stopLat = stopLat;
    }

    public double getStopLon() {
        return stopLon;
    }

    public void setStopLon(double stopLon) {
        this.stopLon = stopLon;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }
}
