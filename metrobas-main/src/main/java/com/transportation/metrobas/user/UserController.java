package com.transportation.metrobas.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserAdabter userAdabter;

    private final UserService userService;

    @Autowired
    public UserController(UserAdabter userAdabter, UserService userService) {
        this.userAdabter = userAdabter;
        this.userService = userService;
    }

    @GetMapping
    public ResponseEntity<List<UserDto>> findAllUsers(){
        List<User> users = this.userService.findAllUsers();
        List<UserDto> userDtoList = new ArrayList<>();
        for(User user : users){
            userDtoList.add(userAdabter.UserToDto(user));
        }
        return ResponseEntity.ok(userDtoList);
    }

    @GetMapping("/{userId}")
    public ResponseEntity<UserDto> findUserById(@PathVariable("userId") int userId){
        UserDto userDto = userAdabter.UserToDto(this.userService.findUserById(userId));
        return ResponseEntity.ok(userDto);
    }

    @PutMapping("/{userId}")
    public ResponseEntity<String> updateUserNameOfUser(@PathVariable("userId") int userId ,@RequestParam("userName") String userName){
        this.userService.updateUserNameOfUser(userId, userName);
        return ResponseEntity.ok("User Updated Successfully");
    }
}
