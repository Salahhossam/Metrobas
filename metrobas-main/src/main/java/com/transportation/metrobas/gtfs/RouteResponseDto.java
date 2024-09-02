package com.transportation.metrobas.gtfs;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.List;

public class RouteResponseDto {

    private String routeId;

    private String routeShortName;

    private String routeLongName;

    private BigDecimal rent;

    private String agencyName;

    public RouteResponseDto() {
    }

    public RouteResponseDto(String routeId, String routeShortName, String routeLongName, BigDecimal rent, String agency) {
        this.routeId = routeId;
        this.routeShortName = routeShortName;
        this.routeLongName = routeLongName;
        this.rent = rent;
        this.agencyName = agency;
    }

    public String getRouteId() {
        return routeId;
    }

    public void setRouteId(String routeId) {
        this.routeId = routeId;
    }

    public String getRouteShortName() {
        return routeShortName;
    }

    public void setRouteShortName(String routeShortName) {
        this.routeShortName = routeShortName;
    }

    public String getRouteLongName() {
        return routeLongName;
    }

    public void setRouteLongName(String routeLongName) {
        this.routeLongName = routeLongName;
    }

    public BigDecimal getRent() {
        return rent;
    }

    public void setRent(BigDecimal rent) {
        this.rent = rent;
    }


    public String getAgencyName() {
        return agencyName;
    }

    public void setAgencyName(String agencyName) {
        this.agencyName = agencyName;
    }
}
