function unmock -a cmd arg
    functions --erase $cmd'_'$arg
end