package com.transportation.metrobas.journey;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class JourneyController {

    private final JourneyService journeyService;

    @Autowired
    public JourneyController(JourneyService journeyService) {
        this.journeyService = journeyService;
    }

    @PostMapping("/journey")
    public List<JourneyResponse> getJourney(@Valid @RequestBody JourneyRequest journeyRequest){
        return this.journeyService.getJourney(journeyRequest);
    }

}
