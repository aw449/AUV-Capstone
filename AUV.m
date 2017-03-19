classdef AUV < handle
    %Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        position_x
        position_y
        previous_x %for graphing 
        previous_y %for graphing 
        velocity
        border_x
        border_y
        current_knowledge
    end
    
    methods
        function obj = AUV(x,y,v,bound_x,bound_y)
                if nargin == 0
                    x = 1;
                    y = 1;
                    v = 1;
                    bound_x = 100;
                    bound_y = 100;
                end
                
                obj.position_x = x;
                obj.position_y = y;
                obj.previous_x = x;
                obj.previous_y = y;
                obj.velocity = v;
                obj.border_x = bound_x;
                obj.border_y = bound_y;
                obj.current_knowledge = zeros(bound_x,bound_y);
  
        end
        
        function traverse(thisAUV, direction)  
            %Directions are based on array coordinates
            switch direction
                case 'S'
                    if(thisAUV.position_x + thisAUV.velocity < thisAUV.border_x)
                        thisAUV.position_x = thisAUV.position_x + thisAUV.velocity;
                    else
                        warning('Reached edge')
                    end
                case 'N'
                    if(thisAUV.position_x - thisAUV.velocity > 0)
                        thisAUV.position_x = thisAUV.position_x - thisAUV.velocity;
                    else
                       warning('Reached edge')
                    end
                case 'E'
                    if(thisAUV.position_y + thisAUV.velocity < thisAUV.border_y)
                        thisAUV.position_y = thisAUV.position_y + thisAUV.velocity;
                    else
                       warning('Reached edge')
                    end
                case 'W'
                    if(thisAUV.position_y + thisAUV.velocity > 0)
                        thisAUV.position_y = thisAUV.position_y - thisAUV.velocity;
                    else
                       warning('Reached edge')
                    end
                otherwise
                    warning('Direction must be a string: N,S,W,E')
            end
            thisAUV.previous_x = [thisAUV.previous_x, thisAUV.position_x];
            thisAUV.previous_y = [thisAUV.previous_y, thisAUV.position_y];
            
        end
        
        function direction = switchDirection(thisAUV,direction)
            switch direction
                case 'S'
                    direction = 'N';
                case 'N'
                    direction = 'S';
                case 'E'
                    direction = 'W';
                case 'W'
                    direction = 'E';
            end
        
        end
        
        function sample(thisAUV, world)
            thisAUV.current_knowledge(thisAUV.position_x,thisAUV.position_y) = world(thisAUV.position_x,thisAUV.position_y);
        end
        
        function sparseTraverse(thisAUV, step_size, world, direction_long, direction_short)
            %Goes down the full length of direction_long
            %Traverses direction_short for step_size duration
            switch direction_long
                case {'E','W'}
                    long_lim = thisAUV.border_y;
                    short_lim = thisAUV.border_x;
                otherwise
                    long_lim = thisAUV.border_x;
                    short_lim = thisAUV.border_y;
            end
            %Need a condition to stop sparseTraverse if high pollution is
            %detected
            for j = 1:step_size:short_lim
                for i = 1 : long_lim - 1
                    thisAUV.sample(world)
                    thisAUV.traverse(direction_long);
                end
                direction_long = thisAUV.switchDirection(direction_long);
                for x = 1:step_size
                    thisAUV.sample(world)
                    thisAUV.traverse(direction_short)
                end
            end
        end
        

    end
    
end

