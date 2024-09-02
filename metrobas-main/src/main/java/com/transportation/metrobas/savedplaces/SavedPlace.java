package com.transportation.metrobas.savedplaces;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.transportation.metrobas.user.User;
import jakarta.persistence.*;

@Entity
@Table(name = "saved_places")
public class SavedPlace {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "saved_place_id")
    private int savedPlaceId;

    @Column(name = "label")
    private String label;

    @Column(name = "name")
    private String name;

    @Column(name = "stop_lat")
    private double stopLat;

    @Column(name = "stop_lon")
    private double stopLon;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "user_id")
    @JsonBackReference
    private User user;

    public SavedPlace() {
    }

    public SavedPlace(String label, String name, double stopLat, double stopLon) {
        this.label = label;
        this.name = name;
        this.stopLat = stopLat;
        this.stopLon = stopLon;
    }

    public int getSavedPlaceId() {
        return savedPlaceId;
    }

    public void setSavedPlaceId(int savedPlaceId) {
        this.savedPlaceId = savedPlaceId;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @Override
    public String toString() {
        return "SavedPlace{" +
                "savedPlaceId=" + savedPlaceId +
                ", name='" + name + '\'' +
                ", stopLat=" + stopLat +
                ", stopLon=" + stopLon +
                '}';
    }
}
