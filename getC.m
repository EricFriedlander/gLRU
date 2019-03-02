function ohr = getC(c, requests, time, sizes, cache_size, numfiles, obj_id)
    
    requests = double(requests);
    ohr = 0.0;
    sum_val = 0.0;
    for i = 1:numfiles
        sum_val = sum_val + requests(i) * (exp(-double(sizes(obj_id(i)))/c)) * sizes(obj_id(i));
    end
    
    if sum_val <= 0
        return;
    end
    
    
    oP1 = @(T,l,p) (l * p * T * (840.0 + 60.0 * l * T + 20.0 * l*l * T*T + l*l*l * T*T*T));
    oP2 = @(T,l,p) (840.0 + 120.0 * l * (-3.0 + 7.0 * p) * T + 60.0 * l*l * (1.0 + p) * T*T + 4.0 * l*l*l * (-1.0 + 5.0 * p) * T*T*T + l*l*l*l * p * T*T*T*T);

    
    
    the_T = cache_size / double(sum_val);
    for j = 1:20
        the_C = double(0);
        if the_T > 1e70
            break;
        end
        
        for i = 1:numfiles
            admProb = exp(-double(sizes(obj_id(i))/c));
            tmp01 = oP1(the_T, requests(i), admProb);
            tmp02 = oP2(the_T,requests(i), admProb);
            if tmp01 ~= 0 && tmp02 ==   0
                tmp = 0.0;
            else
                tmp = tmp01/tmp02;
            end
            
            if tmp < 0
                tmp = 0.0;
            elseif tmp > 1
                tmp = 1.0;
            end
            
            the_C = the_C + double(sizes(obj_id(i)) * tmp);
        end
        
        old_T = the_T;
        the_T = cache_size * old_T/the_C;
    end
    
    
    
    
    
    
    % Compute OHR
    for i = 1:numfiles
        admProb = exp(-double(sizes(obj_id(i))/c));
        tmp01 = oP1(the_T, requests(i), admProb);
        tmp02 = oP2(the_T, requests(i), admProb);
        if tmp01 ~= 0 && tmp02 ==0
            tmp = 0.0;
        else
            tmp = tmp01/tmp02;
        end

        if tmp < 0
            tmp = 0.0;
        elseif tmp > 1
            tmp = 1.0;
        end
            
        ohr = ohr + double(requests(i) * tmp);
        
    end 
    
end
