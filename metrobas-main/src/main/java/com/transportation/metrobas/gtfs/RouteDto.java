package com.transportation.metrobas.gtfs;


import java.math.BigDecimal;

public class RouteDto {
    private String routeNewName;

    private BigDecimal newRent;

    public RouteDto(String routeNewName, BigDecimal newRent) {
        this.routeNewName = routeNewName;
        this.newRent = newRent;
    }

    public String getRouteNewName() {
        return routeNewName;
    }

    public void setRouteNewName(String routeNewName) {
        this.routeNewName = routeNewName;
    }

    public BigDecimal getNewRent() {
        return newRent;
    }

    public void setNewRent(BigDecimal newRent) {
        this.newRent = newRent;
    }
}
