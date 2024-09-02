package com.transportation.metrobas.journey;

import java.util.ArrayList;
import java.util.List;

public class JourneyResponse {
    private double duration;
    private double totalPrice;
    private int numberOfTransfers;
    private double walkingTime;
    private List<SubTrip> subTrips;
    private List<double[]> journeyPoints;

    public JourneyResponse() {

    }

    public JourneyResponse(double duration, double totalPrice, int numberOfTransfers, double walkingTime) {
        this.duration = duration;
        this.totalPrice = totalPrice;
        this.numberOfTransfers = numberOfTransfers;
        this.walkingTime = walkingTime;
    }

    public double getDuration() {
        return duration;
    }

    public void setDuration(double duration) {
        this.duration = duration;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(
            double totalPrice) {
        this.totalPrice = totalPrice;
    }


    public int getNumberOfTransfers() {
        return numberOfTransfers;
    }

    public void setNumberOfTransfers(int numberOfTransfers) {
        this.numberOfTransfers = numberOfTransfers;
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

    public List<double[]> getJourneyPoints() {
        return journeyPoints;
    }

    public void setJourneyPoints(List<double[]> journeyPoints) {
        this.journeyPoints = journeyPoints;
    }

    public void addTripPoint(double[] point){
        if(this.journeyPoints == null){
            this.journeyPoints = new ArrayList<>();
        }
        this.journeyPoints.add(point);
    }

    @Override
    public String toString() {
        return "JourneyResponse{" +
                "duration=" + duration +
                ", totalPrice=" + totalPrice +
                ", numberOfTransfers=" + numberOfTransfers +
                '}';
    }
}

