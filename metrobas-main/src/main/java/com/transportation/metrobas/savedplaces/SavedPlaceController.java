package com.transportation.metrobas.savedplaces;

import jakarta.validation.Valid;
import jdk.dynalink.linker.LinkerServices;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/saved-places")
public class SavedPlaceController {

    private final SavedPlaceService savedPlaceService;

    @Autowired
    public SavedPlaceController(SavedPlaceService savedPlaceService) {
        this.savedPlaceService = savedPlaceService;
    }

    @PostMapping
    public ResponseEntity<String> createSavedPlace(@Valid @RequestBody SaveSavedPlaceDto saveSavedPlaceDto, Principal principal){
         this.savedPlaceService.createSavedPlace(saveSavedPlaceDto, principal.getName());
         return new ResponseEntity<>("place added successfully", HttpStatus.CREATED);
    }

    @PutMapping("/{savePlaceId}")
    public ResponseEntity<String> updateSavedPlace(@PathVariable("savePlaceId") int savePlaceId , @Valid @RequestBody SaveSavedPlaceDto saveSavedPlaceDto, Principal principal){
        this.savedPlaceService.updateSavedPlace(savePlaceId ,saveSavedPlaceDto, principal.getName());
        return ResponseEntity.ok("place updated successfully");
    }

    @DeleteMapping("/{savePlaceId}")
    public ResponseEntity<String> deleteSavedPlace(@PathVariable("savePlaceId") int savePlaceId){
        this.savedPlaceService.deleteSavedPlace(savePlaceId);
        return ResponseEntity.ok("place deleted successfully");
    }

    @PostMapping("/user/{userId}")
    public List<SavedPlace> getUserSavedPlaces(@PathVariable int userId){
           return this.savedPlaceService.getUserSavedPlaces(userId);
    }

}
