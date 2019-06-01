using DataStructures: OrderedDict
#TODO: seed, copy


mutable struct DictSpace <: AbstractSpace
    spaces::OrderedDict{Union{Symbol, AbstractString}, AbstractSpace}

    DictSpace(spaces::OrderedDict{<:Union{Symbol, AbstractString}, <:AbstractSpace}) =  new(spaces)
    DictSpace(;space_kwargs...) = new(OrderedDict{Symbol, AbstractSpace}(space_kwargs))
end

DictSpace(spaces::Dict{<:Union{Symbol, AbstractString}, <:AbstractSpace})  =
    DictSpace(OrderedDict(sort([(sym, space) for (sym, space) in pairs(spaces)])))

sample(dict_obj::DictSpace) = OrderedDict([(k, sample(space)) for (k, space) in pairs(dict_obj.spaces)])

function contains(x, dict_obj::DictSpace)
    # If x is not a dict or OrderedDict or if x doesn't have the same length as spaces
    if !(isa(x, Dict) || isa(x, OrderedDict)) || length(x) != length(dict_obj.spaces)
        return false
    end

    for (k, space) in pairs(dict_obj.spaces)
        # If k is not in x, or if x[k] ∉ space return false
        (isnothing(get(x, k, nothing)) || !(x[k] ∈ space)) && return false
    end
    return true
end

Base.:(==)(dict_obj::DictSpace, other::DictSpace) = dict_obj.spaces == other.spaces
