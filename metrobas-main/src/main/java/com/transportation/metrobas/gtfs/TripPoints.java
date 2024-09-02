package com.transportation.metrobas.gtfs;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.Objects;

@Entity
@Table(name = "trip_points")
public class TripPoints {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "point_id")
    private int pointId;
    @Column(name = "pt_lat")
    private double pointLatitude;
    @Column(name = "pt_lon")
    private double pointLongitude;
    @Column(name = "pt_sequence")
    private int pointSequence;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "trip_id")
    private Trip trip;


    public TripPoints() {
    }

    public TripPoints(double pointLatitude, double pointLongitude, int pointSequence) {
        this.pointLatitude = pointLatitude;
        this.pointLongitude = pointLongitude;
        this.pointSequence = pointSequence;
    }

    public int getPointId() {
        return pointId;
    }

    public void setPointId(int pointId) {
        this.pointId = pointId;
    }

    public double getPointLatitude() {
        return pointLatitude;
    }

    public void setPointLatitude(double pointLatitude) {
        this.pointLatitude = pointLatitude;
    }

    public double getPointLongitude() {
        return pointLongitude;
    }

    public void setPointLongitude(double pointLongitude) {
        this.pointLongitude = pointLongitude;
    }

    public int getPointSequence() {
        return pointSequence;
    }

    public void setPointSequence(int pointSequence) {
        this.pointSequence = pointSequence;
    }

    public Trip getTrip() {
        return trip;
    }

    public void setTrip(Trip trip) {
        this.trip = trip;
    }

    @Override
    public String toString() {
        return "TripPoints{" +
                "pointId=" + pointId +
                ", pointLatitude=" + pointLatitude +
                ", pointLongitude=" + pointLongitude +
                ", pointSequence=" + pointSequence +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TripPoints that = (TripPoints) o;
        return pointId == that.pointId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(pointId);
    }
}
