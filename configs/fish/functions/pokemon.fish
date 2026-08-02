function pokemon
    set gen (random 1 8)

    # ~10% chance for shiny
    if test (random 1 10) -eq 1
        pokego -s -r $gen
    else
        pokego -r $gen
    end
end
