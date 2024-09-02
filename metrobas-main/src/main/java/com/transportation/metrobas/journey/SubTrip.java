package com.transportation.metrobas.journey;

import java.util.ArrayList;
import java.util.List;

public class SubTrip {

    private String tripId;
    private String tripName;
    private List<String> stopNames;

    public SubTrip() {
    }

    public SubTrip(String tripId, String tripName) {
        this.tripId = tripId;
        this.tripName = tripName;
        this.stopNames = new ArrayList<>();
    }

    public String getTripId() {
        return tripId;
    }

    public void setTripId(String tripId) {
        this.tripId = tripId;
    }

    public String getTripName() {
        return tripName;
    }

    public void setTripName(String tripName) {
        this.tripName = tripName;
    }

    public List<String> getStopNames() {
        return stopNames;
    }

    public void setStopNames(List<String> stopNames) {
        this.stopNames = stopNames;
    }

    public void addStopName(String stopName){
        if(this.stopNames == null){
            this.stopNames = new ArrayList<>();
        }
        this.stopNames.add(stopName);
    }

    public SubTrip copy(){
        SubTrip newSubTrip = new SubTrip();
        newSubTrip.setTripId(this.getTripId());
        newSubTrip.setTripName(this.getTripName());
        for(String s : this.getStopNames()){
            newSubTrip.addStopName(s);
        }
        return newSubTrip;
    }

    @Override
    public String toString() {
        return "SubTrip{" +
                "tripId='" + tripId + '\'' +
                ", tripName='" + tripName + '\'' +
                ", stopNames=" + stopNames +
                '}';
    }
}
