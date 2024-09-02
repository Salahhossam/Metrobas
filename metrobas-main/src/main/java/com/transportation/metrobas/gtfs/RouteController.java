package com.transportation.metrobas.gtfs;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/routes")
public class RouteController {

    private final RouteService routeService;

    @Autowired
    public RouteController(RouteService routeService) {
        this.routeService = routeService;
    }

    @GetMapping
    public ResponseEntity<List<RouteResponseDto>> findAllRoutes(){
        List<Route> routes = this.routeService.findAllRoutes();
        List<RouteResponseDto> routeResponseDtos = new ArrayList<>();
        for(Route route : routes){
            routeResponseDtos.add(new RouteResponseDto(route.getRouteId(), route.getRouteShortName(), route.getRouteLongName(), route.getRent(), route.getAgency().getAgencyName()));
        }
        return ResponseEntity.ok(routeResponseDtos);
    }

    @PutMapping("/routeId")
    public ResponseEntity<String> updateRoute(@PathVariable("routeId") String routeId , @Valid @RequestBody RouteDto routeDto){
        this.routeService.updateRoute(routeDto, routeId);
        return ResponseEntity.ok("Route successfully updated");
    }
}
