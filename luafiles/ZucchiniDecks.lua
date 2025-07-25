SMODS.Atlas {
    -- defines where the joker images are pulled from
    key = "ZucchinisVariousDecks",
    path = "ZucchinisVariousDecks.png",
    px = 71,
    py = 95
}



--function kindly provided by kaedenn, a variation of pseudoshuffle that works with arrays
-- this is unused currently but if i can figure out how to make bologna deck work then this will be used for that
function znm_pseudoshuffle(list, seed)
    if seed then math.randomseed(seed) end

    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
end

-- pinata deck
SMODS.Back {
    key = "pinata",
    loc_txt = {
        name = 'Piñata Deck',
        text = {
            'Start run with {C:attention,T:v_overstock_norm}#1#{},',
            '{C:attention,T:v_magic_trick}#2#{},',
            'and {C:attention,T:v_illusion}#3#{}',
            'Playing cards appear',
            'more often in the {C:attention}shop{}'

        }
    },
    pos = { x = 1, y = 0 },
    atlas = 'ZucchinisVariousDecks',
    config = { vouchers = { 'v_overstock_norm', 'v_magic_trick', 'v_illusion' }, playing_card_rate = 10, znm_card_rate_bool = false },
    loc_vars = function(self, info_queue, back)
        return {
            vars = { localize { type = 'name_text', key = self.config.vouchers[1], set = 'Voucher' },
                localize { type = 'name_text', key = self.config.vouchers[2], set = 'Voucher' }, localize { type = 'name_text', key = self.config.vouchers[3], set = 'Voucher' }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.starting_shop and not self.config.znm_card_rate_bool then
            G.GAME.playing_card_rate = self.config.playing_card_rate
            self.config.znm_card_rate_bool = true
        end
    end




}
-- voucher deck
SMODS.Back {
    key = "rewards",
    loc_txt = {
        name = 'Birthday Deck',
        text = {
            '{C:attention}+#1#{} voucher slot',
            'Start run with {C:money,T:v_clearance_sale}#2#{}',


        }
    },
    pos = { x = 2, y = 0 },
    atlas = 'ZucchinisVariousDecks',
    config = { voucher = 'v_clearance_sale', extra = { voucherslots = 1 } },
    loc_vars = function(self, info_queue, back)
        return {
            vars = { self.config.extra.voucherslots, localize { type = 'name_text', key = self.config.voucher, set = 'Voucher' }
            }
        }
    end,
    apply = function(self, back)
        SMODS.change_voucher_limit(self.config.extra.voucherslots)
    end,

}
-- public deck
SMODS.Back {
    key = "public",
    loc_txt = {
        name = 'My Dog Ate My Deck',
        text = {
            'After defeating each',
            '{C:attention}Boss Blind{}, #1# random',
            'playing cards are {C:attention}destroyed{}',
            '{C:green,s:0.8}Art by Worldwaker2{}'

        }
    },
    pos = { x = 3, y = 0 },
    atlas = 'ZucchinisVariousDecks',
    config = { extra = { cards_destroyed = 4 } },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.cards_destroyed } }
    end,

    calculate = function(self, card, context)
        local destroyed_cards = {}
        local temp_hand = {}




        -- uses the same context as anaglyph deck, i dont really know what the eval bit does but i dont really careeee it WORKS and it works about how i had in my head
        -- destroying functionality taken from immolate so it doesn't hit the same cards multiple times teehee
        if context.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
            for _, playing_card in ipairs(G.playing_cards) do temp_hand[#temp_hand + 1] = playing_card end
            table.sort(temp_hand,
                function(a, b)
                    return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
                end
            )
            pseudoshuffle(temp_hand, pseudoseed('znm_publicdeck'))
            for i = 1, self.config.extra.cards_destroyed do destroyed_cards[#destroyed_cards + 1] = temp_hand[i] end

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    SMODS.destroy_cards(destroyed_cards)
                    return true
                end
            }))
        end
    end


}

-- this doesnt actually like, work the way youd think, so for now baloney deck is dead
--[[
SMODS.Back {
    key = "bologna",
    loc_txt = {
		name = 'Bologna Deck',
		text = {
			'All joker {C:attention}rarities{}',
            'are {C:attention}shuffled{} when',
            'run is started',
            '{C:red}X1.2{} base Blind size'

		}
	},
    pos = { x = 3, y = 0 },
    atlas = 'ZucchinisVariousDecks',
    config = { ante_scaling = 1.2, znm_bologna_bool = false },
    loc_vars = function(self, info_queue, back)
        return { {  self.config.ante_scaling }
            }

    end,


            -- storing the jokers independently from the global joker array is so that i can exclude modded rarities
            -- what this code is going to do is it's going to store all the values of rarities and redistribute them randomly
            apply = function(self, back)
local znm_bologna_rarities = {}
local znm_bologna_jokers = {}


        for i = 1, #G.P_CENTER_POOLS.Joker do
            -- this is the part that actually avoids the modded rarities btw
            if type(G.P_CENTER_POOLS.Joker[i].rarity) == "number" then
            znm_bologna_rarities[i] = G.P_CENTER_POOLS.Joker[i].rarity
            znm_bologna_jokers[i] = G.P_CENTER_POOLS.Joker[i]
            end

        end
                znm_pseudoshuffle(znm_bologna_rarities, pseudoseed('znm_bologna'))
        for i = 1, #znm_bologna_jokers do

            znm_bologna_jokers[i].rarity=znm_bologna_rarities[i]

        end


end





}
]] --


--gooses balatro lava
SMODS.Back {
    key = "firewalk",
    loc_txt = {
        name = 'Firewalking Deck',
        text = {
            -- '{C:blue}+#1#{} hands',
            '{C:blue}+#1#{} hand, {C:attention}+#2#{} joker slot',
            'After defeating each {C:attention}Boss Blind{},',
            'a random Joker is {C:attention}destroyed{}',
            '{C:inactive,s:0.8}({C:attention,s:0.8}Eternal{C:inactive,s:0.8} Jokers instead',
            '{C:inactive,s:0.8}lose their {C:attention,s:0.8}Eternal{C:inactive,s:0.8} sticker)',
            '{C:green,s:0.8}Art by Worldwaker2, Concept by gooseberry{}'

        }
    },
    pos = { x = 4, y = 0 },
    atlas = 'ZucchinisVariousDecks',
    config = { hands = 1, joker_slot = 1 },
    loc_vars = function(self, info_queue, back)
        return {
            vars = { self.config.hands, self.config.joker_slot
            }
        }
    end,

    calculate = function(self, card, context)
        -- uses the same context as anaglyph deck, combined with pretty much just madness code ill be so honest
        if context.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
            local destructable_jokers = {}
            if #G.jokers.cards > 0 then
                for i = 1, #G.jokers.cards do
                    if not G.jokers.cards[i].getting_sliced then
                        destructable_jokers[#destructable_jokers + 1] =
                            G.jokers.cards[i]
                    end
                end
                local joker_to_destroy = pseudorandom_element(destructable_jokers, pseudoseed('znm_molten'))

                if joker_to_destroy then
                    if not joker_to_destroy.ability.eternal then
                        local eval = function() return not G.RESET_JIGGLES end
                        juice_card_until(joker_to_destroy, eval, true)
                        G.E_MANAGER:add_event(Event({

                        }))
                        G.E_MANAGER:add_event(Event({
                            delay = 0.5,
                            func = function()
                                (joker_to_destroy):juice_up(0.8, 0.8)
                                joker_to_destroy:start_dissolve({ G.C.UI.TEXT_DARK }, nil, 1.6)

                                return true
                            end
                        }))
                        return {
                            card_eval_status_text(joker_to_destroy, 'extra', nil, nil, nil, {
                                message = "!!",
                                colour = G.C.ATTENTION
                            }),
                        }
                    else
                        joker_to_destroy:set_eternal(false)
                        return {
                            card_eval_status_text(joker_to_destroy, 'extra', nil, nil, nil, {
                                message = "!!",
                                colour = G.C.RED
                            }),
                        }
                    end
                end
            end
        end
    end


}

-- crystal deck
SMODS.Back {
    key = "crystal",
    loc_txt = {
        name = 'Crystal Deck',
        text = {
            '{C:uncommon}Uncommon{} and {C:rare}Rare{} jokers',
            'appear {C:attention}twice{} as often',



        }
    },
    pos = { x = 5, y = 0 },
    atlas = 'ZucchinisVariousDecks',
    config = { extra = { uncommon_rarity = 2, rare_rarity = 2 } },
    loc_vars = function(self, info_queue, back)
        return {
            vars = { self.config.extra.uncommon_rarity, self.config.extra.rare_rarity
            }
        }
    end,
    apply = function(self, back)
        -- im doing this via multiplication because i have NO idea where the values for these are stored and even less idea what they actually are
        -- realistically speaking its probably wiser anyways though
        G.GAME.uncommon_mod = G.GAME.uncommon_mod * self.config.extra.uncommon_rarity
        G.GAME.rare_mod = G.GAME.rare_mod * self.config.extra.rare_rarity
        -- third line of code for orchid and bosssauce
    end,

}
