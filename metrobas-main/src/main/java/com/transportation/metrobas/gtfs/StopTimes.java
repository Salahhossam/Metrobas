package com.transportation.metrobas.gtfs;
import jakarta.persistence.*;
import java.time.LocalTime;
import java.util.Objects;

@Entity
@Table(name = "stop_times")
public class StopTimes {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stop_time_id")
    private int stopTimeId;

    @Column(name = "arrive_time")
    private LocalTime arriveTime;

    @Column(name = "departure_time")
    private LocalTime departureTime;

    @Column(name = "stop_sequence")
    private int stopSequence;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "trip_id")
    private Trip trip;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "stop_id")
    private Stop stop;


    public StopTimes() {
    }

    public StopTimes(LocalTime arriveTime, LocalTime departureTime, int stopSequence) {
        this.arriveTime = arriveTime;
        this.departureTime = departureTime;
        this.stopSequence = stopSequence;
    }

    public int getStopTimeId() {
        return stopTimeId;
    }

    public void setStopTimeId(int stopTimeId) {
        this.stopTimeId = stopTimeId;
    }

    public LocalTime getArriveTime() {
        return arriveTime;
    }

    public void setArriveTime(LocalTime arriveTime) {
        this.arriveTime = arriveTime;
    }

    public LocalTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalTime departureTime) {
        this.departureTime = departureTime;
    }

    public int getStopSequence() {
        return stopSequence;
    }

    public void setStopSequence(int stopSequence) {
        this.stopSequence = stopSequence;
    }

    public Trip getTrip() {
        return trip;
    }

    public void setTrip(Trip trip) {
        this.trip = trip;
    }

    public Stop getStop() {
        return stop;
    }

    public void setStop(Stop stop) {
        this.stop = stop;
    }


    @Override
    public String toString() {
        return "StopTimes{" +
                "stopTimeId=" + stopTimeId +
                ", arriveTime=" + arriveTime +
                ", departureTime=" + departureTime +
                ", stopSequence=" + stopSequence +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StopTimes stopTimes = (StopTimes) o;
        return stopTimeId == stopTimes.stopTimeId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(stopTimeId);
    }
}
