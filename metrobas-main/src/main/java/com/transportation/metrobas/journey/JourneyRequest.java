package com.transportation.metrobas.journey;

import com.transportation.metrobas.enums.Filter;
import com.transportation.metrobas.enums.Transportation;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.time.LocalTime;
import java.util.List;

public class JourneyRequest {
    @NotNull(message = "Source location cannot be null")
    @Valid
    private Location source;

    @NotNull(message = "Destination location cannot be null")
    @Valid
    private Location destination;

    @NotNull(message = "Time cannot be null")
    private LocalTime time;

    @NotNull(message = "Filter cannot be null")
    private Filter filter;

    @NotEmpty(message = "Transportations list cannot be empty")
    private List<Transportation> transportations;

    public JourneyRequest() {
    }

    public Location getSource() {
        return source;
    }

    public void setSource(Location source) {
        this.source = source;
    }

    public Location getDestination() {
        return destination;
    }

    public void setDestination(Location destination) {
        this.destination = destination;
    }

    public LocalTime getTime() {
        return time;
    }

    public void setTime(LocalTime time) {
        this.time = time;
    }

    public Filter getFilter() {
        return filter;
    }

    public void setFilter(Filter filter) {
        this.filter = filter;
    }

    public List<Transportation> getTransportations() {
        return transportations;
    }

    public void setTransportations(List<Transportation> transportations) {
        this.transportations = transportations;
    }

    @Override
    public String toString() {
        return "JourneyRequest{" +
                "source=" + source +
                ", destination=" + destination +
                ", time=" + time +
                ", filter=" + filter +
                ", transportations=" + transportations +
                '}';
    }
}
