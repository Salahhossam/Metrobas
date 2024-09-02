package com.transportation.metrobas.gtfs;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Entity
@Table(name = "trips")
public class Trip {
    @Id
    @Column(name = "trip_id")
    private String tripId;

    @Column(name = "direction_id")
    private int directionId;

    @Column(name = "trip_headsign")
    private String tripHeadsign;

    @ManyToOne(cascade={CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "route_id")
    private Route route;

    @OneToMany(mappedBy = "trip", cascade = CascadeType.ALL)
    private List<StopTimes> stopTimes;

    @OneToMany(mappedBy = "trip", cascade = CascadeType.ALL)
    private List<TripPoints> tripPoints;

    public Trip() {
    }

    public Trip(String tripId, int directionId, String tripHeadsign) {
        this.tripId = tripId;
        this.directionId = directionId;
        this.tripHeadsign = tripHeadsign;
    }

    public String getTripId() {
        return tripId;
    }

    public void setTripId(String tripId) {
        this.tripId = tripId;
    }

    public int getDirectionId() {
        return directionId;
    }

    public void setDirectionId(int directionId) {
        this.directionId = directionId;
    }

    public String getTripHeadsign() {
        return tripHeadsign;
    }

    public void setTripHeadsign(String tripHeadsign) {
        this.tripHeadsign = tripHeadsign;
    }

    public Route getRoute() {
        return route;
    }

    public void setRoute(Route route) {
        this.route = route;
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

    public List<TripPoints> getTripPoints() {
        return tripPoints;
    }

    public void setTripPoints(List<TripPoints> tripPoints) {
        this.tripPoints = tripPoints;
    }

    public void addTripPoint(TripPoints tripPoint){
        if(this.tripPoints == null){
            this.tripPoints = new ArrayList<>();
        }
        this.tripPoints.add(tripPoint);
    }

    @Override
    public String toString() {
        return "Trip{" +
                "tripId='" + tripId + '\'' +
                ", directionId=" + directionId +
                ", tripHeadsign='" + tripHeadsign + '\'' +
                '}';
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Trip trip = (Trip) o;
        return Objects.equals(tripId, trip.tripId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(tripId);
    }
}
