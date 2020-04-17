export bounds

function bounds(verts::AbstractArray{SVector{N, T}}) where {N, T}
    if isempty(verts) return missing end
    
    min = SVector{N, T}()
    max = SVector{N, T}()
    
    for vert ∈ verts
        for n ∈ 1:N
            min[n] = min(min[n], vert[n])
            max[n] = max(max[n], vert[n])
        end
    end
    
    return min, max
end
