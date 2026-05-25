package com.napoleon.card.service;

import com.napoleon.card.dto.CardResponse;
import com.napoleon.card.dto.UpdateCardRequest;

public interface CardService {
    CardResponse getCard(Long id);
    CardResponse updateCard(UpdateCardRequest request);
}