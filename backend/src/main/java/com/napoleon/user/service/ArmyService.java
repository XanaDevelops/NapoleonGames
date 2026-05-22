package com.napoleon.user.service;

import com.napoleon.user.dto.ArmyResponse;
import com.napoleon.user.dto.SaveArmyRequest;

public interface ArmyService {
    ArmyResponse saveArmy(SaveArmyRequest request);
}