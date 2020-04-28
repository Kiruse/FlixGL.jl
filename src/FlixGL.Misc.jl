export curry, hflip!, vflip!
export mm2in, in2mm

curry(fn, curryargs...; kwcurryargs...) = (moreargs...; kwargs...) -> fn(curryargs..., moreargs...; kwcurryargs..., kwargs...)

function hflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if cols < 2 return arr end
    
    for row ∈ 1:rows
        for col ∈ 1:(cols÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[row, cols-(col-1)]
            arr[row, cols-(col-1)] = tmp
        end
    end
    arr
end

function vflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if rows < 2 return arr end
    
    for col ∈ 1:cols
        for row ∈ 1:(rows÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[rows-(row-1), col]
            arr[rows-(row-1), col] = tmp
        end
    end
    arr
end

mm2in(mm::Number) = 0.03937mm
in2mm(in::Number) = in / 0.03937
