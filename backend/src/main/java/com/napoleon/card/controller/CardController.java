package com.napoleon.card.controller;

import com.napoleon.card.dto.CardResponse;
import com.napoleon.card.dto.UpdateCardRequest;
import com.napoleon.card.service.CardService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/card")
public class CardController {

    private final CardService cardService;

    public CardController(CardService cardService) {
        this.cardService = cardService;
    }

    @GetMapping
    public CardResponse getCard(@RequestParam Long id) {
        return cardService.getCard(id);
    }

    @PostMapping
    public CardResponse updateCard(@Valid @RequestBody UpdateCardRequest request) {
        return cardService.updateCard(request);
    }
}