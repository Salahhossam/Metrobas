package com.transportation.metrobas.auth;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    @Autowired
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@Valid @RequestBody RegisterRequest registerRequest){
        this.authService.register(registerRequest);
        return new ResponseEntity<>("User Created", HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest loginRequest){
        return this.authService.login(loginRequest);
    }

    @PutMapping("/changePassword")
    public ResponseEntity<String> changePassword(@Valid @RequestBody ChangePasswordDto changePasswordDto, Principal principal){
        this.authService.changePassword(changePasswordDto, principal.getName());
        return ResponseEntity.ok("password changes successfully");
    }

    @PostMapping("/block/{userId}")
    public ResponseEntity<String> blockUser(@PathVariable("userId") int userId){
         this.authService.blockUser(userId);
         return ResponseEntity.ok("user is blocked");
    }
}
