package com.transportation.metrobas.journey;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class StopLabel {
    private double totalTime;
    private double walkingTime;
    private List<SubTrip> subTrips;

    public StopLabel() {
    }

    public StopLabel(double totalTime, double walkingTime) {
        this.totalTime = totalTime;
        this.walkingTime = walkingTime;
    }

    public double getTotalTime() {
        return totalTime;
    }

    public void setTotalTime(double totalTime) {
        this.totalTime = totalTime;
    }

    public double getWalkingTime() {
        return walkingTime;
    }

    public void setWalkingTime(double walkingTime) {
        this.walkingTime = walkingTime;
    }

    public List<SubTrip> getSubTrips() {
        return subTrips;
    }

    public void setSubTrips(List<SubTrip> subTrips) {
        this.subTrips = subTrips;
    }

    public void addSubTrip(SubTrip subTrip){
        if(this.subTrips == null){
            this.subTrips = new ArrayList<>();
        }
        this.subTrips.add(subTrip);
    }

    public StopLabel copy(){
        StopLabel newStopLabel = new StopLabel(this.getTotalTime(), this.getWalkingTime());
        if(this.subTrips != null){
            List<SubTrip> newSubTrips = new ArrayList<>();
            for(SubTrip subTrip : this.subTrips){
                newSubTrips.add(subTrip.copy());
            }
            newStopLabel.setSubTrips(newSubTrips);
        }
        return newStopLabel;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StopLabel stopLabel = (StopLabel) o;
        return Double.compare(totalTime, stopLabel.totalTime) == 0 && Double.compare(walkingTime, stopLabel.walkingTime) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hash(totalTime, walkingTime);
    }
}
