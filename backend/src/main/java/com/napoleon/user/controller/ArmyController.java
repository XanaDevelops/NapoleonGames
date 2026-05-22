package com.napoleon.user.controller;

import com.napoleon.user.dto.ArmyResponse;
import com.napoleon.user.dto.SaveArmyRequest;
import com.napoleon.user.service.ArmyService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/army")
public class ArmyController {

    private final ArmyService armyService;

    public ArmyController(ArmyService armyService) {
        this.armyService = armyService;
    }

    @PostMapping
    public ArmyResponse saveArmy(@Valid @RequestBody SaveArmyRequest request) {
        return armyService.saveArmy(request);
    }
}