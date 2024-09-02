package com.transportation.metrobas.savedplaces;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SavedPlaceService {

    private final SavedPlaceRepository savedPlaceRepository;

    private final UserRepository userRepository;

    @Autowired
    public SavedPlaceService(SavedPlaceRepository savedPlaceRepository, UserRepository userRepository) {
        this.savedPlaceRepository = savedPlaceRepository;
        this.userRepository = userRepository;
    }


    @Transactional
    public void createSavedPlace(SaveSavedPlaceDto saveSavedPlaceDto , String userName){
        User user = userRepository.findByUserName(userName).orElseThrow();
        SavedPlace savedPlace = new SavedPlace(saveSavedPlaceDto.getLabel() ,saveSavedPlaceDto.getName(), saveSavedPlaceDto.getStopLat(), saveSavedPlaceDto.getStopLon());
        savedPlace.setUser(user);
        savedPlaceRepository.save(savedPlace);
    }

    @Transactional
    public void updateSavedPlace(int savePlaceId, SaveSavedPlaceDto saveSavedPlaceDto , String userName){
        SavedPlace savedPlace = savedPlaceRepository.findById(savePlaceId).orElseThrow();
        savedPlace.setLabel(saveSavedPlaceDto.getLabel());
        savedPlace.setName(saveSavedPlaceDto.getName());
        savedPlace.setStopLat(saveSavedPlaceDto.getStopLat());
        savedPlace.setStopLon(saveSavedPlaceDto.getStopLon());
        savedPlaceRepository.save(savedPlace);
    }

    @Transactional
    public void deleteSavedPlace(int savePlaceId){
        savedPlaceRepository.deleteById(savePlaceId);
    }

    public List<SavedPlace> getUserSavedPlaces(int userId){
        return this.savedPlaceRepository.findSavedPlacesByUserId(userId);
    }
}
