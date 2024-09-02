package com.transportation.metrobas.gtfs;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Entity
@Table(name = "stops")
public class Stop {

    @Id
    @Column(name = "stop_id")
    private String stopId;

    @Column(name = "stop_name")
    private String stopName;

    @Column(name = "stop_lat")
    private double stopLat;

    @Column(name = "stop_lon")
    private double stopLon;

    @OneToMany(mappedBy = "stop", cascade = CascadeType.ALL)
    private List<StopTimes> stopTimes;

    @OneToMany(mappedBy = "transferStop",cascade = CascadeType.ALL)
    private List<TransferStops> transferStops;

    public Stop() {
    }


    public Stop(String stopId, String stopName, double stopLat, double stopLon) {
        this.stopId = stopId;
        this.stopName = stopName;
        this.stopLat = stopLat;
        this.stopLon = stopLon;
    }

    public String getStopId() {
        return stopId;
    }

    public void setStopId(String stopId) {
        this.stopId = stopId;
    }

    public String getStopName() {
        return stopName;
    }

    public void setStopName(String stopName) {
        this.stopName = stopName;
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

    public List<TransferStops> getTransferStops() {
        return transferStops;
    }

    public void setTransferStops(List<TransferStops> transferStops) {
        this.transferStops = transferStops;
    }

    public void addTransferStop(TransferStops transferStop){
        if(this.transferStops == null){
            this.transferStops = new ArrayList<>();
        }
        this.transferStops.add(transferStop);
    }

    public List<StopTimes> getStopTimes() {
        return stopTimes;
    }

    public void setStopTimes(List<StopTimes> stopTimes) {
        this.stopTimes = stopTimes;
    }

    public void addStopTime(StopTimes stopTime){
        if(this.stopTimes == null){
            this.stopTimes = new ArrayList<>();
        }
        this.stopTimes.add(stopTime);
    }

    @Override
    public String toString() {
        return "Stop{" +
                "stopId='" + stopId + '\'' +
                ", stopName='" + stopName + '\'' +
                ", stopLat=" + stopLat +
                ", stopLon=" + stopLon +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Stop stop = (Stop) o;
        return Objects.equals(stopId, stop.stopId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(stopId);
    }
}
