using SHA
using Dates

mutable struct Block
    index::Int
    timestamp::String
    data::Dict{String, Any}
    previous_hash::String
    hash::String

    function Block(index::Int, timestamp::String, data::Dict{String, <:Any}, previous_hash::String)
        block = new(index, timestamp, Dict{String, Any}(data), previous_hash, "")
        block.hash = calculate_hash(block)
        return block
    end
end

function calculate_hash(block::Block)
    hash_string = string(block.index, block.timestamp, block.data, block.previous_hash)
    return bytes2hex(sha256(hash_string))
end

mutable struct Blockchain
    chain::Vector{Block}

    function Blockchain()
        genesis_block = create_genesis_block()
        new([genesis_block])
    end
end

function create_genesis_block()
    Block(0, Dates.format(now(), "yyyy-mm-ddTHH:MM:SS.sss"), Dict("data" => "Genesis Block"), "0")
end

function get_latest_block(chain::Blockchain)
    return chain.chain[end]
end

function add_block!(chain::Blockchain, data::Dict{String, Any})
    latest_block = get_latest_block(chain)
    new_index = latest_block.index + 1
    new_timestamp = Dates.format(now(), "yyyy-mm-ddTHH:MM:SS.sss")
    new_block = Block(new_index, new_timestamp, data, latest_block.hash)
    push!(chain.chain, new_block)
end
