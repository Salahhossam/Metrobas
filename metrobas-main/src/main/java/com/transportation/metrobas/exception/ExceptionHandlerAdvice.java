package com.transportation.metrobas.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class ExceptionHandlerAdvice {

    @ExceptionHandler
    public ResponseEntity<ErrorResponse> handleUserNotFoundException(UsernameNotFoundException usernameNotFoundException){
        ErrorResponse errorResponse = new ErrorResponse();
        errorResponse.setStatus(HttpStatus.NOT_FOUND.value());
        errorResponse.setMessage(usernameNotFoundException.getMessage());
        errorResponse.setTimeStamp(System.currentTimeMillis());
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException methodArgumentNotValidException) {
        ErrorResponse errorResponse = new ErrorResponse();
        errorResponse.setStatus(HttpStatus.BAD_REQUEST.value());
        StringBuilder message = new StringBuilder();
        for (FieldError fieldError : methodArgumentNotValidException.getBindingResult().getFieldErrors()) {
            message.append(fieldError.getDefaultMessage());
        }
        errorResponse.setMessage(message.toString());
        errorResponse.setTimeStamp(System.currentTimeMillis());
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler
    public ResponseEntity<ErrorResponse> handlException(Exception e){
        ErrorResponse errorResponse = new ErrorResponse();
        errorResponse.setStatus(HttpStatus.BAD_REQUEST.value());
        errorResponse.setMessage(e.getMessage());
        errorResponse.setTimeStamp(System.currentTimeMillis());
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    private class ErrorResponse{
        private int status;
        private String message;
        private long timeStamp;

        public ErrorResponse() {
        }

        public ErrorResponse(int status, String message, long timeStamp) {
            this.status = status;
            this.message = message;
            this.timeStamp = timeStamp;
        }

        public int getStatus() {
            return status;
        }

        public void setStatus(int status) {
            this.status = status;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public long getTimeStamp() {
            return timeStamp;
        }

        public void setTimeStamp(long timeStamp) {
            this.timeStamp = timeStamp;
        }
    }


}
