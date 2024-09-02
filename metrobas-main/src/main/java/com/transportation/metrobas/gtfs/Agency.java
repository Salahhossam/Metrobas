package com.transportation.metrobas.gtfs;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Entity
@Table(name = "agency")
public class Agency {
    // fields
    @Id
    @Column(name = "agency_id")
    private String agencyId;

    @Column(name = "agency_name")
    private String agencyName;

    @Column(name = "agency_url")
    private String agencyUrl;

    @OneToMany(mappedBy = "agency", cascade = CascadeType.ALL)
    private List<Route> routes;

    // constructor

    public Agency() {
    }

    public Agency(String agencyId, String agencyName, String agencyUrl) {
        this.agencyId = agencyId;
        this.agencyName = agencyName;
        this.agencyUrl = agencyUrl;
    }


// getters/setters

    public String getAgencyId() {
        return agencyId;
    }

    public void setAgencyId(String agencyId) {
        this.agencyId = agencyId;
    }

    public String getAgencyName() {
        return agencyName;
    }

    public void setAgencyName(String agencyName) {
        this.agencyName = agencyName;
    }

    public String getAgencyUrl() {
        return agencyUrl;
    }

    public void setAgencyUrl(String agencyUrl) {
        this.agencyUrl = agencyUrl;
    }

    public List<Route> getRoutes() {
        return routes;
    }

    public void setRoutes(List<Route> routes) {
        this.routes = routes;
    }

    public void addRoute(Route route){
        if(this.routes == null){
            routes = new ArrayList<>();
        }
        this.routes.add(route);
    }

    // toString()
    @Override
    public String toString() {
        return "Agency{" +
                "agencyId='" + agencyId + '\'' +
                ", agencyName='" + agencyName + '\'' +
                ", agencyUrl='" + agencyUrl + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Agency agency = (Agency) o;
        return Objects.equals(agencyId, agency.agencyId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(agencyId);
    }
}
