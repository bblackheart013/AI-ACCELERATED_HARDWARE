#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <string.h>
#include <unistd.h> // For usleep on macOS

// Configuration
#define VECTOR_SIZE 8
#define DATA_WIDTH 16
#define NUM_TESTS 10000
#define LARGE_VECTOR_SIZE 1024
#define SIMULATION_MODE 1 // Set to 0 if running on actual hardware

typedef uint16_t data_t;

// Simulate hardware acceleration
void hardware_vector_multiply(const data_t *vector_a, const data_t *vector_b,
															data_t *result, int size)
{
	// In simulation mode, we'll use a time factor to simulate hardware speedup
	if (SIMULATION_MODE)
	{
		// Simulate parallel execution by reducing time proportional to vector size
		usleep(1); // Minimal delay for hardware - all elements computed in parallel

		// Still need to compute the result for validation
		for (int i = 0; i < size; i++)
		{
			result[i] = vector_a[i] * vector_b[i];
		}
	}
	else
	{
		// Actual hardware would go here if available
		// This code would communicate with the FPGA
		// For now, we're just simulating the result
		for (int i = 0; i < size; i++)
		{
			result[i] = vector_a[i] * vector_b[i];
		}
	}
}

// Software implementation
void software_vector_multiply(const data_t *vector_a, const data_t *vector_b,
															data_t *result, int size)
{
	// Single-threaded CPU implementation
	for (int i = 0; i < size; i++)
	{
		result[i] = vector_a[i] * vector_b[i];
	}
}

// For macOS compatibility
double get_time_sec()
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return ts.tv_sec + ts.tv_nsec / 1000000000.0;
}

// Run performance test
void run_performance_test(int vector_size)
{
	data_t *vector_a = (data_t *)malloc(sizeof(data_t) * vector_size);
	data_t *vector_b = (data_t *)malloc(sizeof(data_t) * vector_size);
	data_t *hw_result = (data_t *)malloc(sizeof(data_t) * vector_size);
	data_t *sw_result = (data_t *)malloc(sizeof(data_t) * vector_size);

	double start, end;
	double hw_time, sw_time;

	// Initialize vectors with test data
	for (int i = 0; i < vector_size; i++)
	{
		vector_a[i] = (i % 100) + 1; // Avoid overflow
		vector_b[i] = ((vector_size - i) % 100) + 1;
	}

	// Hardware accelerated multiplication (timed)
	start = get_time_sec();
	for (int j = 0; j < NUM_TESTS; j++)
	{
		hardware_vector_multiply(vector_a, vector_b, hw_result, vector_size);
	}
	end = get_time_sec();

	hw_time = end - start;

	// Software multiplication (timed)
	start = get_time_sec();
	for (int j = 0; j < NUM_TESTS; j++)
	{
		software_vector_multiply(vector_a, vector_b, sw_result, vector_size);
	}
	end = get_time_sec();

	sw_time = end - start;

	// Verify results match
	int match = 1;
	for (int i = 0; i < vector_size; i++)
	{
		if (hw_result[i] != sw_result[i])
		{
			match = 0;
			printf("Mismatch at index %d: HW=%d, SW=%d\n", i, hw_result[i], sw_result[i]);
			break;
		}
	}

	// Print performance results
	printf("Vector Size: %d\n", vector_size);
	printf("Hardware time: %.6f seconds\n", hw_time);
	printf("Software time: %.6f seconds\n", sw_time);
	printf("Speedup: %.2f x\n", sw_time / hw_time);
	printf("Results %s\n\n", match ? "match" : "do not match");

	// Free allocated memory
	free(vector_a);
	free(vector_b);
	free(hw_result);
	free(sw_result);
}

// This function simulates how performance scales with vector size
void show_scaling_performance()
{
	printf("\nScaling Performance (simulated):\n");
	printf("----------------------------\n");
	printf("| Vector Size | Speedup   |\n");
	printf("----------------------------\n");

	// Theoretical speedup based on vector size
	// Hardware parallelism means constant time regardless of size
	// Software scales linearly with size
	for (int size = 8; size <= 4096; size *= 2)
	{
		// Theoretical model: hardware time is constant, software scales with size
		// Include some overhead for very small sizes
		double theoretical_speedup = size / (1.0 + 8.0 / size);
		printf("| %-11d | %-9.2f |\n", size, theoretical_speedup);
	}
	printf("----------------------------\n");

	printf("\nNote: This shows theoretical scaling based on\n");
	printf("parallelism. Actual hardware would have additional\n");
	printf("factors like memory bandwidth and transfer overhead.\n");
}

int main()
{
	printf("Vector Multiplication Performance Test\n");
	printf("======================================\n\n");

	// Test with different vector sizes to show scaling
	printf("Running tests with standard vector size (%d)...\n", VECTOR_SIZE);
	run_performance_test(VECTOR_SIZE);

	// Test with larger vector size to demonstrate scaling advantage
	printf("Running tests with large vector size (%d)...\n", LARGE_VECTOR_SIZE);
	run_performance_test(LARGE_VECTOR_SIZE);

	// Show theoretical scaling for different vector sizes
	show_scaling_performance();

	return 0;
}