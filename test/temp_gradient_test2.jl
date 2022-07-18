using Surrogates
using Zygote
using Optim
using ForwardDiff

function vector_of_tuples_to_matrix(v)
    #convert training data generated by surrogate sampling into a matrix suitable for GEKPLS
    num_rows = length(v)
    num_cols = length(first(v))
    K = zeros(num_rows, num_cols)
    for row in 1:num_rows
        for col in 1:num_cols
            K[row, col] = v[row][col]
        end
    end
    return K
end

function vector_of_tuples_to_matrix2(v)
    #convert gradients into matrix form
    num_rows = length(v)
    num_cols = length(first(first(v)))
    K = zeros(num_rows, num_cols)
    for row in 1:num_rows
        for col in 1:num_cols
            K[row, col] = v[row][1][col]
        end
    end
    return K
end


function rmse(a,b)
    #to calculate root mean squared error
    a = vec(a)
    b = vec(b)
    if(size(a)!=size(b))
        println("error in inputs")
        return
    end
    n = size(a,1)
    return sqrt(sum((a - b).^2)/n)
end

function sphere_function(x)
    return sum(x .^ 2)
end

n = 50
d = 3
lb = [-10.0 for i in 1:d]
ub = [10.0 for i in 1:3]
x = sample(n, lb, ub, SobolSample())
X = vector_of_tuples_to_matrix(x)
grads = vector_of_tuples_to_matrix2(gradient.(sphere_function, x))
y = reshape(sphere_function.(x), (size(x, 1), 1))
xlimits = hcat(lb, ub)

n_test = 20
x_test = sample(n_test, lb, ub, GoldenSample())
X_test = vector_of_tuples_to_matrix(x_test)
y_true = sphere_function.(x_test)


n_comp = 2
delta_x = 0.0001
extra_points = 2
initial_theta = [0.01 for i in 1:n_comp]
#g = GEKPLS(X, y, grads, n_comp, delta_x, xlimits, extra_points, initial_theta)
#y_pred = g(X_test)
g = GEKPLS(X, y, grads, n_comp, delta_x, xlimits, extra_points, initial_theta)
#gradient(g, [1.0 1.0 1.0]) #works fine

ForwardDiff.gradient(g, [1.0 1.0 1.0]) 


# function minimize_func(theta)
#     println("hi from minimize_func")
#     println(theta)
#     g = GEKPLS(X, y, grads, n_comp, delta_x, xlimits, extra_points, theta)
#     y_pred = g(X_test)
#     return rmse(y_true, y_pred)
# end

# theta = [0.0, 0.0]
# res = optimize(minimize_func, theta)
# Optim.minimizer(res)
# res1 = optimize(minimize_func, theta, LBFGS()) # PosDefException: matrix is not positive definite; Cholesky factorization failed.
# res2 = optimize(minimize_func, theta, Newton(), autodiff=:finite) #PosDefException: matrix is not positive definite; Cholesky factorization failed.
#gradient(h, 3.0, 5.0)


#gradient(minimize_func, [0.01, 0.01]) #works!
#ForwardDiff.gradient(minimize_func, [0.01, 0.01]) #works!
# minimize_func'([0.01, 0.01])

# ForwardDiff.gradient(minimize_func, [0.01, 0.01])

# function min_rlfv(theta)
#     g = GEKPLS(X, y, grads, n_comp, delta_x, xlimits, extra_points, theta)
#     return -g.reduced_likelihood_function_value
# end

# gradient(min_rlfv, [0.01, 0.1])

#using FiniteDiff
#fd = FiniteDiff.finite_difference_gradient(mean_lp, [1.0, 2.0])
# FiniteDiff.finite_difference_gradient(min_rlfv, [0.01, 0.01])


#home grown optimizer below
# thetas = [[0.1, 0.1], [1.0, 1.0]]

# best_theta = [0.01, 0.01]
# best_score = Inf

# for theta in thetas
#     current_score = minimize_func(theta)
#     if (current_score < best_score)
#         best_score = current_score
#         best_theta = theta
#     end
# end

# best_theta
#home grown optimizer above