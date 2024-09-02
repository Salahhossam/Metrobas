package com.transportation.metrobas.gtfs;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class RouteService {

    private final RouteRepository routeRepository;

    @Autowired
    public RouteService(RouteRepository routeRepository) {
        this.routeRepository = routeRepository;
    }

    public List<Route> findAllRoutes(){
        return this.routeRepository.findAll();
    }

    @Transactional
    public void updateRoute(RouteDto routeDto, String routeId){
        Route route = this.routeRepository.findById(routeId).orElseThrow();
        route.setRouteShortName(routeDto.getRouteNewName());
        route.setRent(routeDto.getNewRent());
        this.routeRepository.save(route);
    }
}
